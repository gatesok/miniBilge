using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Diagnostics;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Options;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3-T02: Kota tüketim ve günlük reset. P3-T04: Aynı hesabın iki cihazda kullanımı.
public class DailyUsageServiceTests : IDisposable
{
    private const string Feature = "adaptive_quiz"; // Free=1, Premium=10
    private readonly ApplicationDbContext _context;
    private readonly DailyUsageService _service;

    public DailyUsageServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            // InMemory transaction desteklemez; ConsumeAsync serializable transaction kullanır.
            .ConfigureWarnings(w => w.Ignore(InMemoryEventId.TransactionIgnoredWarning))
            .Options;
        _context = new ApplicationDbContext(options);
        _service = new DailyUsageService(
            _context,
            Options.Create(new DailyUsageOptions()),
            new SubscriptionService());
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private (Guid userId, Guid childId) SeedFamily(bool premium = false)
    {
        var userId = Guid.NewGuid();
        var parentProfileId = Guid.NewGuid();
        var childId = Guid.NewGuid();

        var user = new User { Id = userId, Email = $"{userId}@t.local", Role = UserRole.Parent };
        var parent = new ParentProfile { Id = parentProfileId, UserId = userId, User = user };
        var child = new ChildProfile
        {
            Id = childId,
            ParentProfileId = parentProfileId,
            ParentProfile = parent,
            Name = "Çocuk",
        };
        if (premium)
        {
            user.Subscriptions.Add(new UserSubscription
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Provider = SubscriptionProvider.Apple,
                Status = SubscriptionStatus.Active,
                ExpiresAt = DateTime.UtcNow.AddMonths(1),
                CreatedAt = DateTime.UtcNow,
            });
        }

        _context.Users.Add(user);
        _context.ParentProfiles.Add(parent);
        _context.ChildProfiles.Add(child);
        _context.SaveChanges();
        return (userId, childId);
    }

    [Fact]
    public async Task Consume_UcretsizLimiteKadar_SonrasindaReddedilir()
    {
        var (userId, childId) = SeedFamily();

        var first = await _service.ConsumeAsync(userId, childId, Feature);
        first.Remaining.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, Feature);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    [Fact]
    public async Task Consume_HerCagri_UsageEventKaydeder()
    {
        var (userId, childId) = SeedFamily();

        await _service.ConsumeAsync(userId, childId, Feature);

        _context.UsageEvents.Count(x => x.EventType == "consume").Should().Be(1);
    }

    [Fact]
    public async Task Consume_GecmisGuneAitKayit_BugunuEtkilemez_GunlukReset()
    {
        var (userId, childId) = SeedFamily();
        // Dün limit dolmuş; bugün tam hak olmalı (kayıt UsageDate'e göre tutulur).
        _context.DailyFeatureUsages.Add(new DailyFeatureUsage
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            FeatureKey = Feature,
            UsageDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1)),
            UsedCount = 99,
            CreatedAt = DateTime.UtcNow.AddDays(-1),
        });
        _context.SaveChanges();

        var status = await _service.GetStatusAsync(userId, childId, Feature);

        status.UsedCount.Should().Be(0);
        status.Remaining.Should().Be(1);
        status.Allowed.Should().BeTrue();
    }

    [Fact]
    public async Task Consume_PremiumKullanici_YuksekLimit()
    {
        var (userId, childId) = SeedFamily(premium: true);

        MiniBilge.Application.DTOs.Usage.DailyUsageStatusDto last = null!;
        for (var i = 0; i < 10; i++)
            last = await _service.ConsumeAsync(userId, childId, Feature);

        last.BaseLimit.Should().Be(10);
        last.Remaining.Should().Be(0);
    }

    // P3-T04: Aynı hesap (aynı çocuk) iki farklı cihazdan tüketince kota SUNUCUDA paylaşılır.
    [Fact]
    public async Task IkiCihaz_AyniCocuk_KotaPaylasilir()
    {
        var (userId, childId) = SeedFamily();

        // Cihaz A hakkı tüketir; cihaz B aynı sunucu kotasını görür.
        await _service.ConsumeAsync(userId, childId, Feature); // device A

        _context.DailyFeatureUsages.Count().Should().Be(1);
        var row = _context.DailyFeatureUsages.Single();
        row.UsedCount.Should().Be(1);

        // İkinci cihaz denemesi paylaşılan kotayı aşar.
        var act = async () => await _service.ConsumeAsync(userId, childId, Feature);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Meydan okuma teknik hatayla oluşturulamazsa tüketilen hak geri verilir.
    [Fact]
    public async Task Refund_TuketilenHakGeriVerilir_YenidenTuketilebilir()
    {
        var (userId, childId) = SeedFamily(); // adaptive_quiz Free=1

        var afterConsume = await _service.ConsumeAsync(userId, childId, Feature);
        afterConsume.Remaining.Should().Be(0);

        // Telafi: bir hak geri ver.
        var afterRefund = await _service.RefundAsync(userId, childId, Feature);
        afterRefund.UsedCount.Should().Be(0);
        afterRefund.Remaining.Should().Be(1);

        // Geri verilen hak tekrar tüketilebilir olmalı.
        var reconsume = await _service.ConsumeAsync(userId, childId, Feature);
        reconsume.Remaining.Should().Be(0);
    }

    // Hiç tüketim yokken telafi sayacı negatife düşürmez.
    [Fact]
    public async Task Refund_TuketimYokken_SayacNegatifOlmaz()
    {
        var (userId, childId) = SeedFamily();

        var status = await _service.RefundAsync(userId, childId, Feature);
        status.UsedCount.Should().Be(0);
        status.Remaining.Should().Be(status.BaseLimit);
    }

    private const string AdultChallenge = "adult_challenge"; // Free=3, Premium=20, bonus=2

    // Ürün kuralı: Free kullanıcı günde 3 yetişkin meydan okuması başlatabilir.
    [Fact]
    public async Task AdultChallenge_FreeUcHak_DorduncudeReddedilir()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 3; i++)
            await _service.ConsumeAsync(userId, childId, AdultChallenge);

        var act = async () => await _service.ConsumeAsync(userId, childId, AdultChallenge);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Reklamsız modelde ödüllü bonus talepleri hak kazandırmaz.
    [Fact]
    public async Task AdultChallenge_ReklamBonusuDevreDisi()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 3; i++)
            await _service.ConsumeAsync(userId, childId, AdultChallenge);

        var status = await _service.GrantRewardedBonusAsync(
            userId, childId, AdultChallenge);
        status.RewardedBonusCount.Should().Be(0);
        status.RewardedBonusLimit.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, AdultChallenge);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Ürün kuralı: Premium 20 hak, ödüllü bonus yok (limit 0), 21. reddedilir.
    [Fact]
    public async Task AdultChallenge_Premium_YirmiHak_BonusYok()
    {
        var (userId, childId) = SeedFamily(premium: true);

        MiniBilge.Application.DTOs.Usage.DailyUsageStatusDto last = null!;
        for (var i = 0; i < 20; i++)
            last = await _service.ConsumeAsync(userId, childId, AdultChallenge);

        last.BaseLimit.Should().Be(20);
        last.Remaining.Should().Be(0);
        last.RewardedBonusLimit.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, AdultChallenge);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    private const string LiveMatch = "live_match"; // Free=5, Premium=30, bonus=2

    // Ürün kuralı: Free kullanıcı günde 5 canlı yarış başlatabilir; 6. reddedilir.
    [Fact]
    public async Task LiveMatch_FreeBesHak_AltincidaReddedilir()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 5; i++)
            await _service.ConsumeAsync(userId, childId, LiveMatch);

        var act = async () => await _service.ConsumeAsync(userId, childId, LiveMatch);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Reklamsız modelde canlı maç bonus talepleri hak kazandırmaz.
    [Fact]
    public async Task LiveMatch_ReklamBonusuDevreDisi()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 5; i++)
            await _service.ConsumeAsync(userId, childId, LiveMatch);

        var status = await _service.GrantRewardedBonusAsync(
            userId, childId, LiveMatch);
        status.RewardedBonusCount.Should().Be(0);
        status.RewardedBonusLimit.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, LiveMatch);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Ürün kuralı: Premium 30 canlı yarış hakkı ("sınırsız" değil); 31. reddedilir.
    [Fact]
    public async Task LiveMatch_Premium_OtuzHak_OtuzBirdeReddedilir()
    {
        var (userId, childId) = SeedFamily(premium: true);

        MiniBilge.Application.DTOs.Usage.DailyUsageStatusDto last = null!;
        for (var i = 0; i < 30; i++)
            last = await _service.ConsumeAsync(userId, childId, LiveMatch);

        last.BaseLimit.Should().Be(30);
        last.Remaining.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, LiveMatch);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Rakip bulunamaz/iptal edilirse rezerve edilen hak iade edilir (yeniden tüketilebilir).
    [Fact]
    public async Task LiveMatch_IptalIadesi_HakGeriVerilir()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 5; i++)
            await _service.ConsumeAsync(userId, childId, LiveMatch);
        // Limit doldu.
        var full = async () => await _service.ConsumeAsync(userId, childId, LiveMatch);
        await full.Should().ThrowAsync<DailyUsageLimitExceededException>();

        // İptal → bir hak iade.
        var afterRefund = await _service.RefundAsync(userId, childId, LiveMatch);
        afterRefund.Remaining.Should().Be(1);

        // İade edilen hak tekrar tüketilebilir.
        var reconsume = await _service.ConsumeAsync(userId, childId, LiveMatch);
        reconsume.Remaining.Should().Be(0);
    }

    // İki cihazdan eşzamanlı (ardışık) tüketim tek satırda toplanır, limit aşılmaz.
    [Fact]
    public async Task LiveMatch_IkiCihaz_KotaPaylasilir_LimitAsilmaz()
    {
        var (userId, childId) = SeedFamily();

        for (var i = 0; i < 5; i++)
            await _service.ConsumeAsync(userId, childId, LiveMatch); // A/B karışık

        _context.DailyFeatureUsages.Count(x => x.FeatureKey == LiveMatch).Should().Be(1);
        _context.DailyFeatureUsages.Single(x => x.FeatureKey == LiveMatch).UsedCount.Should().Be(5);

        var act = async () => await _service.ConsumeAsync(userId, childId, LiveMatch);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    // Dün limit dolmuş olsa da bugün 5 hak yenilenir (Türkiye günü UsageDate ile tutulur).
    [Fact]
    public async Task LiveMatch_GunlukReset_DunDolu_BugunTamHak()
    {
        var (userId, childId) = SeedFamily();
        _context.DailyFeatureUsages.Add(new DailyFeatureUsage
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            FeatureKey = LiveMatch,
            UsageDate = DateOnly.FromDateTime(DateTime.UtcNow.AddDays(-1)),
            UsedCount = 5,
            CreatedAt = DateTime.UtcNow.AddDays(-1),
        });
        _context.SaveChanges();

        var status = await _service.GetStatusAsync(userId, childId, LiveMatch);
        status.UsedCount.Should().Be(0);
        status.Remaining.Should().Be(5);
        status.Allowed.Should().BeTrue();
    }
}
