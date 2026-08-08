using System.Data;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MiniBilge.Application.DTOs.Usage;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public sealed class DailyUsageService : IDailyUsageService
{
    private readonly ApplicationDbContext _db;
    private readonly DailyUsageOptions _options;
    private readonly ISubscriptionService _subscriptionService;

    public DailyUsageService(
        ApplicationDbContext db,
        IOptions<DailyUsageOptions> options,
        ISubscriptionService subscriptionService)
    {
        _db = db;
        _options = options.Value;
        _subscriptionService = subscriptionService;
    }

    public async Task<DailyUsageStatusDto> GetStatusAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default)
    {
        var context = await ResolveContextAsync(
            userId, childProfileId, featureKey, cancellationToken);
        var usage = await FindTodayAsync(
            childProfileId, context.FeatureKey, context.Today, cancellationToken);
        return ToDto(context, usage);
    }

    public async Task<DailyUsageStatusDto> ConsumeAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync(
            IsolationLevel.Serializable, cancellationToken);
        var context = await ResolveContextAsync(
            userId, childProfileId, featureKey, cancellationToken);
        var usage = await GetOrCreateTodayAsync(
            childProfileId, context.FeatureKey, context.Today, cancellationToken);

        var status = ToDto(context, usage);
        if (!status.Allowed)
            throw new DailyUsageLimitExceededException(status);

        usage.UsedCount++;
        usage.UpdatedAt = DateTime.UtcNow;
        AppendEvent(userId, childProfileId, context, "consume", usage.UsedCount);
        await _db.SaveChangesAsync(cancellationToken);
        await transaction.CommitAsync(cancellationToken);
        return ToDto(context, usage);
    }

    public async Task<DailyUsageStatusDto> RefundAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync(
            IsolationLevel.Serializable, cancellationToken);
        var context = await ResolveContextAsync(
            userId, childProfileId, featureKey, cancellationToken);
        var usage = await GetOrCreateTodayAsync(
            childProfileId, context.FeatureKey, context.Today, cancellationToken);

        // Yalnızca tüketilmiş bir hak varsa geri ver; aksi halde durumu değiştirme.
        if (usage.UsedCount > 0)
        {
            usage.UsedCount--;
            usage.UpdatedAt = DateTime.UtcNow;
            AppendEvent(userId, childProfileId, context, "refund", usage.UsedCount);
            await _db.SaveChangesAsync(cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
        return ToDto(context, usage);
    }

    public async Task<DailyUsageStatusDto> GrantRewardedBonusAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default)
    {
        await using var transaction = await _db.Database.BeginTransactionAsync(
            IsolationLevel.Serializable, cancellationToken);
        var context = await ResolveContextAsync(
            userId, childProfileId, featureKey, cancellationToken);
        var usage = await GetOrCreateTodayAsync(
            childProfileId, context.FeatureKey, context.Today, cancellationToken);

        if (!context.IsPremium &&
            usage.RewardedBonusCount < context.RewardedBonusLimit)
        {
            usage.RewardedBonusCount++;
            usage.UpdatedAt = DateTime.UtcNow;
            AppendEvent(userId, childProfileId, context, "rewarded_bonus", usage.RewardedBonusCount);
            await _db.SaveChangesAsync(cancellationToken);
        }

        await transaction.CommitAsync(cancellationToken);
        return ToDto(context, usage);
    }

    private async Task<UsageContext> ResolveContextAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken)
    {
        var normalizedKey = featureKey.Trim().ToLowerInvariant();
        if (!_options.Features.TryGetValue(normalizedKey, out var limits))
            throw new ArgumentException("Bilinmeyen kullanım özelliği.");

        // usage_quotas override (satır yoksa config kullanılır).
        var quota = await _db.UsageQuotas
            .AsNoTracking()
            .SingleOrDefaultAsync(
                x => x.FeatureKey == normalizedKey && x.IsActive && !x.IsDeleted,
                cancellationToken);
        var freeLimit = quota?.FreeLimit ?? limits.Free;
        var premiumLimit = quota?.PremiumLimit ?? limits.Premium;
        var rewardedBonusLimit =
            quota?.RewardedBonusLimit ?? _options.RewardedBonusLimit;

        var profile = await _db.ChildProfiles
            .AsNoTracking()
            .Include(x => x.ParentProfile)
                .ThenInclude(x => x.User)
                    .ThenInclude(x => x.Subscriptions)
            .SingleOrDefaultAsync(
                x => x.Id == childProfileId && !x.IsDeleted,
                cancellationToken)
            ?? throw new KeyNotFoundException("Profil bulunamadı.");

        if (profile.ParentProfile.UserId != userId)
            throw new UnauthorizedAccessException("Bu profile erişim yetkiniz yok.");

        var now = DateTime.UtcNow;
        var isPremium = _subscriptionService.IsPremium(
            profile.ParentProfile.User.Subscriptions, now);

        return new UsageContext(
            normalizedKey,
            TodayInTurkey(),
            isPremium,
            isPremium ? premiumLimit : freeLimit,
            rewardedBonusLimit);
    }

    private void AppendEvent(
        Guid userId,
        Guid childProfileId,
        UsageContext context,
        string eventType,
        int usedCountAfter)
    {
        _db.UsageEvents.Add(new UsageEvent
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            ChildProfileId = childProfileId,
            FeatureKey = context.FeatureKey,
            EventType = eventType,
            UsageDate = context.Today,
            IsPremium = context.IsPremium,
            UsedCountAfter = usedCountAfter,
            CreatedAt = DateTime.UtcNow,
        });
    }

    private Task<DailyFeatureUsage?> FindTodayAsync(
        Guid childProfileId,
        string featureKey,
        DateOnly today,
        CancellationToken cancellationToken)
    {
        return _db.DailyFeatureUsages
            .AsNoTracking()
            .SingleOrDefaultAsync(
                x => x.ChildProfileId == childProfileId &&
                     x.FeatureKey == featureKey &&
                     x.UsageDate == today,
                cancellationToken);
    }

    private async Task<DailyFeatureUsage> GetOrCreateTodayAsync(
        Guid childProfileId,
        string featureKey,
        DateOnly today,
        CancellationToken cancellationToken)
    {
        var usage = await _db.DailyFeatureUsages.SingleOrDefaultAsync(
            x => x.ChildProfileId == childProfileId &&
                 x.FeatureKey == featureKey &&
                 x.UsageDate == today,
            cancellationToken);
        if (usage != null) return usage;

        usage = new DailyFeatureUsage
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            FeatureKey = featureKey,
            UsageDate = today,
            CreatedAt = DateTime.UtcNow,
        };
        _db.DailyFeatureUsages.Add(usage);
        return usage;
    }

    private DailyUsageStatusDto ToDto(
        UsageContext context,
        DailyFeatureUsage? usage)
    {
        var used = usage?.UsedCount ?? 0;
        var bonus = context.IsPremium ? 0 : usage?.RewardedBonusCount ?? 0;
        if (context.BaseLimit < 0)
        {
            return new DailyUsageStatusDto
            {
                FeatureKey = context.FeatureKey,
                UsageDate = context.Today,
                IsPremium = context.IsPremium,
                BaseLimit = -1,
                UsedCount = used,
                RewardedBonusCount = 0,
                RewardedBonusLimit = 0,
                Remaining = -1,
                Allowed = true,
            };
        }
        var total = context.BaseLimit + bonus;
        var remaining = Math.Max(0, total - used);
        return new DailyUsageStatusDto
        {
            FeatureKey = context.FeatureKey,
            UsageDate = context.Today,
            IsPremium = context.IsPremium,
            BaseLimit = context.BaseLimit,
            UsedCount = used,
            RewardedBonusCount = bonus,
            RewardedBonusLimit = context.IsPremium
                ? 0
                : context.RewardedBonusLimit,
            Remaining = remaining,
            Allowed = remaining > 0,
        };
    }

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

    private sealed record UsageContext(
        string FeatureKey,
        DateOnly Today,
        bool IsPremium,
        int BaseLimit,
        int RewardedBonusLimit);
}

public sealed class DailyUsageLimitExceededException
    : InvalidOperationException
{
    public DailyUsageLimitExceededException(DailyUsageStatusDto status)
        : base("Günlük kullanım hakkınız doldu.")
    {
        Status = status;
    }

    public DailyUsageStatusDto Status { get; }
}
