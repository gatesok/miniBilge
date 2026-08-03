using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.DailyPlan;
using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

// P5-B03: Günlük planı getirme (yoksa üret+kaydet, varsa döndür) integration testleri.
public class DailyPlanServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly DailyPlanService _service;
    private readonly Mock<IParentReportingService> _reporting = new();

    public DailyPlanServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _reporting
            .Setup(r => r.GetWeakTopicsAsync(It.IsAny<Guid>(), It.IsAny<int>()))
            .ReturnsAsync(new List<WeakTopicDto>());
        _service = new DailyPlanService(
            _context, new DailyPlanGenerator(), new SubscriptionService(), _reporting.Object);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private (Guid userId, Guid childId) SeedFamily()
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
            GradeLevel = GradeLevel.Grade2,
            EnglishLevel = EnglishLevel.A1,
        };

        _context.Users.Add(user);
        _context.ParentProfiles.Add(parent);
        _context.ChildProfiles.Add(child);
        _context.SaveChanges();
        return (userId, childId);
    }

    [Fact]
    public async Task GetTodayPlan_ilk_cagride_standart_plan_uretip_kaydeder()
    {
        var (userId, childId) = SeedFamily();

        var dto = await _service.GetTodayPlanAsync(userId, childId);

        dto.Id.Should().NotBe(Guid.Empty);
        dto.Status.Should().Be("pending");
        dto.Source.Should().Be("standard");
        dto.Items.Should().HaveCount(2);
        dto.Items.Select(i => i.ActivityType).Should().ContainInOrder("math", "english_vocab");

        (await _context.DailyPlans.CountAsync()).Should().Be(1);
        (await _context.DailyPlanItems.CountAsync()).Should().Be(2);
    }

    [Fact]
    public async Task GetTodayPlan_ikinci_cagride_ayni_plani_doner_yeni_uretmez()
    {
        var (userId, childId) = SeedFamily();

        var first = await _service.GetTodayPlanAsync(userId, childId);
        var second = await _service.GetTodayPlanAsync(userId, childId);

        second.Id.Should().Be(first.Id);
        (await _context.DailyPlans.CountAsync()).Should().Be(1);
        (await _context.DailyPlanItems.CountAsync()).Should().Be(2);
    }

    [Fact]
    public async Task GetTodayPlan_baska_kullanicinin_profili_icin_reddeder()
    {
        var (_, childId) = SeedFamily();
        var otherUser = Guid.NewGuid();

        var act = async () => await _service.GetTodayPlanAsync(otherUser, childId);

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task GetTodayPlan_olmayan_profil_icin_bulunamadi_firlatir()
    {
        var (userId, _) = SeedFamily();

        var act = async () => await _service.GetTodayPlanAsync(userId, Guid.NewGuid());

        await act.Should().ThrowAsync<KeyNotFoundException>();
    }

    [Fact]
    public async Task CompleteItem_ilk_madde_tamamlaninca_plan_in_progress_olur()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);
        var firstItem = plan.Items.First().Id;

        var updated = await _service.CompleteItemAsync(userId, childId, firstItem);

        updated.Status.Should().Be("in_progress");
        updated.CompletedItems.Should().Be(1);
        updated.Items.Single(i => i.Id == firstItem).IsCompleted.Should().BeTrue();
    }

    [Fact]
    public async Task CompleteItem_tum_maddeler_tamamlaninca_plan_completed_olur()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);

        DailyPlanDto? updated = null;
        foreach (var item in plan.Items)
            updated = await _service.CompleteItemAsync(userId, childId, item.Id);

        updated!.Status.Should().Be("completed");
        updated.CompletedItems.Should().Be(plan.TotalItems);
        updated.CompletedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task CompleteItem_idempotent_ikinci_cagride_degismez()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);
        var itemId = plan.Items.First().Id;

        var first = await _service.CompleteItemAsync(userId, childId, itemId);
        var completedAt = first.Items.Single(i => i.Id == itemId).CompletedAt;
        var second = await _service.CompleteItemAsync(userId, childId, itemId);

        second.CompletedItems.Should().Be(1);
        second.Items.Single(i => i.Id == itemId).CompletedAt.Should().Be(completedAt);
    }

    [Fact]
    public async Task CompleteItem_baska_kullanici_reddedilir()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);
        var itemId = plan.Items.First().Id;

        var act = async () =>
            await _service.CompleteItemAsync(Guid.NewGuid(), childId, itemId);

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }

    [Fact]
    public async Task CompleteItem_olmayan_madde_icin_bulunamadi_firlatir()
    {
        var (userId, childId) = SeedFamily();
        await _service.GetTodayPlanAsync(userId, childId);

        var act = async () =>
            await _service.CompleteItemAsync(userId, childId, Guid.NewGuid());

        await act.Should().ThrowAsync<KeyNotFoundException>();
    }

    [Fact]
    public async Task CompleteItem_plan_tamamlaninca_yildiz_puan_ve_streak_odulu_verir()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);
        var starsBefore = (await _context.ChildProfiles.SingleAsync(c => c.Id == childId)).TotalStars;

        DailyPlanDto? updated = null;
        foreach (var item in plan.Items)
            updated = await _service.CompleteItemAsync(userId, childId, item.Id);

        updated!.RewardGranted.Should().BeTrue();
        updated.RewardStars.Should().BeGreaterThan(0);
        updated.RewardPoints.Should().BeGreaterThan(0);

        var child = await _context.ChildProfiles.SingleAsync(c => c.Id == childId);
        child.TotalStars.Should().Be(starsBefore + updated.RewardStars);
        child.CurrentStreak.Should().Be(1);
        child.LongestStreak.Should().Be(1);
        child.LastActivityDate.Should().Be(DateOnly.FromDateTime(DateTime.UtcNow));

        var progress = await _context.Set<ChildProgress>().SingleAsync(p => p.ChildId == childId);
        progress.TotalScore.Should().Be(updated.RewardPoints);
    }

    [Fact]
    public async Task CompleteItem_odul_idempotent_yildiz_puan_bir_kez_verilir()
    {
        var (userId, childId) = SeedFamily();
        var plan = await _service.GetTodayPlanAsync(userId, childId);

        foreach (var item in plan.Items)
            await _service.CompleteItemAsync(userId, childId, item.Id);

        var starsAfterFirst = (await _context.ChildProfiles.SingleAsync(c => c.Id == childId)).TotalStars;
        var scoreAfterFirst = (await _context.Set<ChildProgress>().SingleAsync(p => p.ChildId == childId)).TotalScore;

        // Zaten tamamlanmış maddeye tekrar çağrı — ödül tekrar verilmemeli.
        await _service.CompleteItemAsync(userId, childId, plan.Items.First().Id);

        var child = await _context.ChildProfiles.SingleAsync(c => c.Id == childId);
        var progress = await _context.Set<ChildProgress>().SingleAsync(p => p.ChildId == childId);
        child.TotalStars.Should().Be(starsAfterFirst);
        progress.TotalScore.Should().Be(scoreAfterFirst);
    }

    [Fact]
    public async Task GetTodayPlan_uretim_hatasinda_fallback_plan_uretip_kaydeder()
    {
        var (userId, childId) = SeedFamily();
        var service = new DailyPlanService(
            _context, new ThrowingGenerator(), new SubscriptionService(), _reporting.Object);

        var dto = await service.GetTodayPlanAsync(userId, childId);

        dto.Source.Should().Be("fallback");
        dto.Items.Should().NotBeEmpty();
        (await _context.DailyPlans.CountAsync()).Should().Be(1);
        (await _context.DailyPlanItems.CountAsync()).Should().Be(dto.Items.Count);
    }

    [Fact]
    public async Task GetTodayPlan_premium_ve_zayif_konu_varsa_kisisellestirilmis_plan_uretir()
    {
        var (userId, childId) = SeedFamily();
        SeedPremium(userId);
        _reporting
            .Setup(r => r.GetWeakTopicsAsync(childId, It.IsAny<int>()))
            .ReturnsAsync(new List<WeakTopicDto>
            {
                new() { TopicId = Guid.NewGuid(), TopicName = "Kesirler", SubjectName = "Matematik", TotalAttempts = 10, CorrectAttempts = 3, SuccessRate = 0.3m },
                new() { TopicId = Guid.NewGuid(), TopicName = "Fiiller", SubjectName = "İngilizce", TotalAttempts = 8, CorrectAttempts = 4, SuccessRate = 0.5m },
            });

        var dto = await _service.GetTodayPlanAsync(userId, childId);

        dto.Source.Should().Be("personalized");
        dto.IsPremiumPersonalized.Should().BeTrue();
        dto.Items.Should().HaveCount(3);
        dto.Items[0].Title.Should().Contain("Kesirler");
        dto.Items[0].RouteKey.Should().StartWith("topic:");
        dto.Items[1].Title.Should().Contain("Fiiller");
    }

    [Fact]
    public async Task GetTodayPlan_premium_ama_zayif_konu_yoksa_standart_plan_uretir()
    {
        var (userId, childId) = SeedFamily();
        SeedPremium(userId);
        // _reporting varsayılan olarak boş liste döner.

        var dto = await _service.GetTodayPlanAsync(userId, childId);

        dto.Source.Should().Be("standard");
        dto.IsPremiumPersonalized.Should().BeFalse();
        dto.Items.Should().HaveCount(2);
    }

    [Fact]
    public async Task GetTodayPlan_premium_degilse_zayif_konu_olsa_bile_standart_plan_uretir()
    {
        var (userId, childId) = SeedFamily();
        _reporting
            .Setup(r => r.GetWeakTopicsAsync(childId, It.IsAny<int>()))
            .ReturnsAsync(new List<WeakTopicDto>
            {
                new() { TopicId = Guid.NewGuid(), TopicName = "Kesirler", SubjectName = "Matematik", TotalAttempts = 10, CorrectAttempts = 3, SuccessRate = 0.3m },
            });

        var dto = await _service.GetTodayPlanAsync(userId, childId);

        dto.Source.Should().Be("standard");
        dto.IsPremiumPersonalized.Should().BeFalse();
    }

    private void SeedPremium(Guid userId)
    {
        _context.UserSubscriptions.Add(new UserSubscription
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Provider = SubscriptionProvider.GooglePlay,
            Status = SubscriptionStatus.Active,
            ProductId = "minibilge_premium_monthly",
            PurchasedAt = DateTime.UtcNow.AddDays(-1),
            ExpiresAt = DateTime.UtcNow.AddDays(29),
            LastVerifiedAt = DateTime.UtcNow,
        });
        _context.SaveChanges();
    }

    // Standart üretimi başarısız olan, yalnızca fallback üreten generator (B06 testi).
    private sealed class ThrowingGenerator : IDailyPlanGenerator
    {
        private readonly DailyPlanGenerator _real = new();

        public DailyPlan Generate(ChildProfile profile, DateOnly planDate)
            => throw new InvalidOperationException("içerik üretilemedi");

        public DailyPlan GeneratePersonalized(
            ChildProfile profile, DateOnly planDate, IReadOnlyList<WeakTopicDto> weakTopics)
            => throw new InvalidOperationException("içerik üretilemedi");

        public DailyPlan GenerateFallback(ChildProfile profile, DateOnly planDate)
            => _real.GenerateFallback(profile, planDate);
    }
}
