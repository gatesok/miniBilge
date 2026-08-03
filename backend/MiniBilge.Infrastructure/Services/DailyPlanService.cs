using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Common;
using MiniBilge.Application.DTOs.DailyPlan;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public sealed class DailyPlanService : IDailyPlanService
{
    private readonly ApplicationDbContext _db;
    private readonly IDailyPlanGenerator _generator;

    public DailyPlanService(ApplicationDbContext db, IDailyPlanGenerator generator)
    {
        _db = db;
        _generator = generator;
    }

    public async Task<DailyPlanDto> GetTodayPlanAsync(
        Guid userId, Guid childProfileId, CancellationToken cancellationToken = default)
    {
        var profile = await _db.ChildProfiles
            .Include(x => x.ParentProfile)
            .SingleOrDefaultAsync(
                x => x.Id == childProfileId && !x.IsDeleted, cancellationToken)
            ?? throw new KeyNotFoundException("Profil bulunamadı.");

        if (profile.ParentProfile.UserId != userId)
            throw new UnauthorizedAccessException("Bu profile erişim yetkiniz yok.");

        var today = TodayInTurkey();

        var existing = await FindPlanAsync(childProfileId, today, cancellationToken);
        if (existing is not null)
            return ToDto(existing);

        // Standart üretim eksik içerik/servis hatasıyla başarısız olursa fallback plana düş.
        DailyPlan plan;
        try
        {
            plan = _generator.Generate(profile, today);
        }
        catch
        {
            plan = _generator.GenerateFallback(profile, today);
        }

        _db.DailyPlans.Add(plan);
        try
        {
            await _db.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            // Eşzamanlı ilk istek planı önce oluşturmuş olabilir (unique index).
            _db.Entry(plan).State = EntityState.Detached;
            foreach (var item in plan.Items)
                _db.Entry(item).State = EntityState.Detached;

            var raced = await FindPlanAsync(childProfileId, today, cancellationToken);
            if (raced is null)
                throw;
            return ToDto(raced);
        }

        return ToDto(plan);
    }

    public async Task<DailyPlanDto> CompleteItemAsync(
        Guid userId, Guid childProfileId, Guid itemId,
        CancellationToken cancellationToken = default)
    {
        var plan = await _db.DailyPlans
            .Include(p => p.Items.Where(i => !i.IsDeleted))
            .Include(p => p.ChildProfile)
                .ThenInclude(c => c.ParentProfile)
            .SingleOrDefaultAsync(
                p => p.ChildProfileId == childProfileId
                    && !p.IsDeleted
                    && p.Items.Any(i => i.Id == itemId && !i.IsDeleted),
                cancellationToken)
            ?? throw new KeyNotFoundException("Plan maddesi bulunamadı.");

        if (plan.ChildProfile.ParentProfile.UserId != userId)
            throw new UnauthorizedAccessException("Bu profile erişim yetkiniz yok.");

        var item = plan.Items.Single(i => i.Id == itemId);
        if (item.IsCompleted)
            return ToDto(plan);

        var now = DateTime.UtcNow;
        item.IsCompleted = true;
        item.CompletedAt = now;
        item.UpdatedAt = now;

        plan.CompletedItems = plan.Items.Count(i => i.IsCompleted);
        if (plan.TotalItems > 0 && plan.CompletedItems >= plan.TotalItems)
        {
            plan.Status = DailyPlanStatus.Completed;
            plan.CompletedAt ??= now;
            await GrantCompletionRewardAsync(plan, now, cancellationToken);
        }
        else if (plan.Status == DailyPlanStatus.Pending)
        {
            plan.Status = DailyPlanStatus.InProgress;
        }
        plan.UpdatedAt = now;

        await _db.SaveChangesAsync(cancellationToken);
        return ToDto(plan);
    }

    // Plan tamamlanınca yıldız + leaderboard puanı + streak ödülünü bir kez uygular
    // (RewardGranted idempotency).
    private async Task GrantCompletionRewardAsync(
        DailyPlan plan, DateTime now, CancellationToken cancellationToken)
    {
        if (plan.RewardGranted)
            return;

        var child = plan.ChildProfile;

        // Yıldız → profil (leaderboard tie-break) + ChildProgress takibi.
        child.TotalStars += plan.RewardStars;

        // Puan → ChildProgress.TotalScore (çocuk leaderboard sıralaması).
        var progress = await _db.Set<ChildProgress>()
            .SingleOrDefaultAsync(p => p.ChildId == child.Id, cancellationToken);
        if (progress is null)
        {
            progress = new ChildProgress
            {
                Id = Guid.NewGuid(),
                ChildId = child.Id,
                TotalScore = plan.RewardPoints,
                TotalStars = plan.RewardStars,
                CompletedLevelsCount = 0,
            };
            _db.Set<ChildProgress>().Add(progress);
        }
        else
        {
            progress.TotalScore += plan.RewardPoints;
            progress.TotalStars += plan.RewardStars;
            progress.UpdatedAt = now;
        }

        var today = DateOnly.FromDateTime(now);
        if (child.LastActivityDate != today)
        {
            var streak = StreakCalculator.Next(
                child.CurrentStreak, child.LastActivityDate, today);
            child.CurrentStreak = streak;
            if (streak > child.LongestStreak)
                child.LongestStreak = streak;
            child.LastActivityDate = today;
        }
        child.UpdatedAt = now;

        plan.RewardGranted = true;
    }

    private Task<DailyPlan?> FindPlanAsync(
        Guid childProfileId, DateOnly planDate, CancellationToken cancellationToken)
        => _db.DailyPlans
            .AsNoTracking()
            .Include(x => x.Items.Where(i => !i.IsDeleted))
            .SingleOrDefaultAsync(
                x => x.ChildProfileId == childProfileId
                    && x.PlanDate == planDate
                    && !x.IsDeleted,
                cancellationToken);

    private static DailyPlanDto ToDto(DailyPlan plan) => new()
    {
        Id = plan.Id,
        PlanDate = plan.PlanDate,
        Status = MapStatus(plan.Status),
        Source = plan.Source,
        IsPremiumPersonalized = plan.IsPremiumPersonalized,
        TotalItems = plan.TotalItems,
        CompletedItems = plan.CompletedItems,
        CompletedAt = plan.CompletedAt,
        RewardStars = plan.RewardStars,
        RewardPoints = plan.RewardPoints,
        RewardGranted = plan.RewardGranted,
        Items = plan.Items
            .OrderBy(i => i.Order)
            .Select(i => new DailyPlanItemDto
            {
                Id = i.Id,
                Order = i.Order,
                ActivityType = i.ActivityType,
                Title = i.Title,
                RouteKey = i.RouteKey,
                TargetCount = i.TargetCount,
                IsCompleted = i.IsCompleted,
                CompletedAt = i.CompletedAt,
            })
            .ToList(),
    };

    private static string MapStatus(DailyPlanStatus status) => status switch
    {
        DailyPlanStatus.InProgress => "in_progress",
        DailyPlanStatus.Completed => "completed",
        _ => "pending",
    };

    private static DateOnly TodayInTurkey()
    {
        try
        {
            var zone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
            return DateOnly.FromDateTime(
                TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone));
        }
        catch (TimeZoneNotFoundException)
        {
            return DateOnly.FromDateTime(DateTime.UtcNow.AddHours(3));
        }
    }
}
