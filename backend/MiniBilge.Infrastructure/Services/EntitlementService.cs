using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// İki katmanlı cache: "fresh" (kısa TTL) hızlı yol, "last-known-good" (uzun TTL)
/// yalnızca DB erişimi başarısız olduğunda fallback için kullanılır.
/// </summary>
public sealed class EntitlementService : IEntitlementService
{
    private static readonly TimeSpan FreshTtl = TimeSpan.FromSeconds(60);
    private static readonly TimeSpan LastKnownGoodTtl = TimeSpan.FromHours(24);

    private readonly ApplicationDbContext _db;
    private readonly ISubscriptionService _subscriptionService;
    private readonly IMemoryCache _cache;
    private readonly ILogger<EntitlementService> _logger;

    public EntitlementService(
        ApplicationDbContext db,
        ISubscriptionService subscriptionService,
        IMemoryCache cache,
        ILogger<EntitlementService> logger)
    {
        _db = db;
        _subscriptionService = subscriptionService;
        _cache = cache;
        _logger = logger;
    }

    public async Task<EntitlementSnapshot> GetForUserAsync(
        Guid userId, CancellationToken cancellationToken = default)
    {
        if (_cache.TryGetValue(FreshKey(userId), out EntitlementSnapshot? fresh) &&
            fresh is not null)
        {
            return fresh;
        }

        try
        {
            var subscriptions = await _db.UserSubscriptions
                .AsNoTracking()
                .Where(x => x.UserId == userId && !x.IsDeleted)
                .ToListAsync(cancellationToken);
            var active = _subscriptionService.GetActiveSubscription(subscriptions);
            var snapshot = EntitlementSnapshot.From(active);

            _cache.Set(FreshKey(userId), snapshot, FreshTtl);
            _cache.Set(LastKnownGoodKey(userId), snapshot, LastKnownGoodTtl);
            return snapshot;
        }
        catch (Exception ex)
        {
            // Güvenli fallback: son bilinen değer varsa onu ver (ödeme yapan kullanıcıyı
            // geçici DB kesintisinde mağdur etme); yoksa premium-değil (fail-closed).
            _logger.LogWarning(
                ex, "Entitlement DB sorgusu başarısız; last-known-good deneniyor.");
            if (_cache.TryGetValue(
                    LastKnownGoodKey(userId), out EntitlementSnapshot? lastKnown) &&
                lastKnown is not null)
            {
                return lastKnown;
            }

            return EntitlementSnapshot.NotPremium;
        }
    }

    public void Invalidate(Guid userId)
    {
        // Yalnızca taze girişi kaldır; last-known-good fallback için korunur.
        _cache.Remove(FreshKey(userId));
    }

    private static string FreshKey(Guid userId) => $"entitlement:{userId}";
    private static string LastKnownGoodKey(Guid userId) => $"entitlement:lkg:{userId}";
}
