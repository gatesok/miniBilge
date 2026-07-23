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

    public DailyUsageService(
        ApplicationDbContext db,
        IOptions<DailyUsageOptions> options)
    {
        _db = db;
        _options = options.Value;
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
        await _db.SaveChangesAsync(cancellationToken);
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
            usage.RewardedBonusCount < _options.RewardedBonusLimit)
        {
            usage.RewardedBonusCount++;
            usage.UpdatedAt = DateTime.UtcNow;
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
        var isPremium = profile.ParentProfile.User.Subscriptions.Any(x =>
            !x.IsDeleted &&
            (x.Status == SubscriptionStatus.Active ||
             x.Status == SubscriptionStatus.GracePeriod) &&
            x.ExpiresAt > now);

        return new UsageContext(
            normalizedKey,
            TodayInTurkey(),
            isPremium,
            isPremium ? limits.Premium : limits.Free);
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
                : _options.RewardedBonusLimit,
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
        int BaseLimit);
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
