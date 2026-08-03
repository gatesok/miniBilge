namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Google Play Developer API üzerinden abonelik satın alma durumunu doğrular.
/// </summary>
public interface IGooglePlayPurchaseVerifier
{
    Task<VerifiedGooglePlaySubscription> VerifyAsync(
        string purchaseToken,
        CancellationToken cancellationToken = default);
}

/// <summary>
/// purchases.subscriptionsv2.get sonucunun ihtiyaç duyulan özeti.
/// </summary>
public sealed record VerifiedGooglePlaySubscription(
    string ProductId,
    DateTime? ExpiresAt,
    // SUBSCRIPTION_STATE_ACTIVE, ..._IN_GRACE_PERIOD, ..._CANCELED, ..._ON_HOLD,
    // ..._PAUSED, ..._EXPIRED, ..._PENDING
    string SubscriptionState,
    string? ObfuscatedExternalAccountId,
    string? LatestOrderId,
    string? LinkedPurchaseToken,
    bool IsTest);
