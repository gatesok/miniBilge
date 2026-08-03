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
    private const string Feature = "adaptive_quiz"; // Free=2, Premium=20 (varsayılan config)
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
        var second = await _service.ConsumeAsync(userId, childId, Feature);

        first.Remaining.Should().Be(1);
        second.Remaining.Should().Be(0);

        var act = async () => await _service.ConsumeAsync(userId, childId, Feature);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }

    [Fact]
    public async Task Consume_HerCagri_UsageEventKaydeder()
    {
        var (userId, childId) = SeedFamily();

        await _service.ConsumeAsync(userId, childId, Feature);
        await _service.ConsumeAsync(userId, childId, Feature);

        _context.UsageEvents.Count(x => x.EventType == "consume").Should().Be(2);
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
        status.Remaining.Should().Be(2);
        status.Allowed.Should().BeTrue();
    }

    [Fact]
    public async Task Consume_PremiumKullanici_YuksekLimit()
    {
        var (userId, childId) = SeedFamily(premium: true);

        MiniBilge.Application.DTOs.Usage.DailyUsageStatusDto last = null!;
        for (var i = 0; i < 20; i++)
            last = await _service.ConsumeAsync(userId, childId, Feature);

        last.BaseLimit.Should().Be(20);
        last.Remaining.Should().Be(0);
    }

    // P3-T04: Aynı hesap (aynı çocuk) iki farklı cihazdan tüketince kota SUNUCUDA paylaşılır.
    [Fact]
    public async Task IkiCihaz_AyniCocuk_KotaPaylasilir()
    {
        var (userId, childId) = SeedFamily();

        // Cihaz A ve Cihaz B ardışık tüketir → tek günlük satırda toplanır.
        await _service.ConsumeAsync(userId, childId, Feature); // device A
        await _service.ConsumeAsync(userId, childId, Feature); // device B

        _context.DailyFeatureUsages.Count().Should().Be(1);
        var row = _context.DailyFeatureUsages.Single();
        row.UsedCount.Should().Be(2);

        // Üçüncü cihaz denemesi paylaşılan kotayı aşar.
        var act = async () => await _service.ConsumeAsync(userId, childId, Feature);
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
    }
}
