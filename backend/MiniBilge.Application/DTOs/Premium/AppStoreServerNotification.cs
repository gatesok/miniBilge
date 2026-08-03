namespace MiniBilge.Application.DTOs.Premium;

/// <summary>Doğrulanmış App Store Server Notification (V2) özeti.</summary>
public sealed record AppStoreServerNotification(
    string NotificationType,
    string? Subtype,
    string NotificationUuid,
    string BundleId,
    string Environment,
    AppStoreTransactionInfo? Transaction);

public sealed record AppStoreTransactionInfo(
    string TransactionId,
    string OriginalTransactionId,
    string ProductId,
    DateTime PurchasedAt,
    DateTime? ExpiresAt,
    DateTime? RevokedAt,
    Guid? AppAccountToken);
