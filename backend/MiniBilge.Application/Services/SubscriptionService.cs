using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public sealed class SubscriptionService : ISubscriptionService
{
    public UserSubscription? GetActiveSubscription(
        IEnumerable<UserSubscription> subscriptions, DateTime? nowUtc = null)
    {
        var now = nowUtc ?? DateTime.UtcNow;
        return subscriptions
            .Where(s =>
                !s.IsDeleted &&
                (s.Status == SubscriptionStatus.Active ||
                 s.Status == SubscriptionStatus.GracePeriod) &&
                s.ExpiresAt > now)
            .OrderByDescending(s => s.ExpiresAt)
            .FirstOrDefault();
    }

    public bool IsPremium(
        IEnumerable<UserSubscription> subscriptions, DateTime? nowUtc = null)
        => GetActiveSubscription(subscriptions, nowUtc) != null;
}
