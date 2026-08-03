using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public sealed class AppStoreNotificationHandler : IAppStoreNotificationHandler
{
    private readonly ApplicationDbContext _db;

    public AppStoreNotificationHandler(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task HandleAsync(
        AppStoreServerNotification notification,
        CancellationToken cancellationToken = default)
    {
        // Idempotency: aynı notificationUUID daha önce işlendiyse hiçbir şey yapma.
        var alreadyProcessed = await _db.PurchaseTransactions.AnyAsync(
            x => x.Provider == SubscriptionProvider.Apple &&
                 x.DedupKey == notification.NotificationUuid,
            cancellationToken);
        if (alreadyProcessed)
            return;

        var now = DateTime.UtcNow;
        var transaction = notification.Transaction;
        Guid? userId = transaction?.AppAccountToken;
        SubscriptionStatus? status = null;

        if (transaction != null)
        {
            status = ComputeStatus(notification, transaction, now);

            var subscription = await _db.UserSubscriptions.SingleOrDefaultAsync(
                x => x.Provider == SubscriptionProvider.Apple &&
                     x.OriginalTransactionId == transaction.OriginalTransactionId,
                cancellationToken);

            // Abonelik daha önce verify ile oluşmadıysa ve kullanıcıyı biliyorsak oluştur.
            if (subscription == null && userId.HasValue)
            {
                subscription = new UserSubscription
                {
                    Id = Guid.NewGuid(),
                    UserId = userId.Value,
                    Provider = SubscriptionProvider.Apple,
                    OriginalTransactionId = transaction.OriginalTransactionId,
                    CreatedAt = now,
                };
                _db.UserSubscriptions.Add(subscription);
            }

            if (subscription != null)
            {
                userId ??= subscription.UserId;
                subscription.ProductId = transaction.ProductId;
                subscription.Environment = notification.Environment;
                subscription.PurchasedAt = transaction.PurchasedAt;
                subscription.ExpiresAt = transaction.ExpiresAt ?? subscription.ExpiresAt;
                subscription.RevokedAt = transaction.RevokedAt;
                subscription.Status = status.Value;
                subscription.LastVerifiedAt = now;
                subscription.UpdatedAt = now;
            }
        }

        _db.PurchaseTransactions.Add(new PurchaseTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Provider = SubscriptionProvider.Apple,
            DedupKey = notification.NotificationUuid,
            Source = "app_store_notification",
            NotificationType = notification.Subtype is null
                ? notification.NotificationType
                : $"{notification.NotificationType}:{notification.Subtype}",
            OriginalTransactionId = transaction?.OriginalTransactionId,
            TransactionId = transaction?.TransactionId,
            ProductId = transaction?.ProductId,
            Environment = notification.Environment,
            Status = status,
            PurchasedAt = transaction?.PurchasedAt,
            ExpiresAt = transaction?.ExpiresAt,
            ProcessedAt = now,
            CreatedAt = now,
        });

        await _db.SaveChangesAsync(cancellationToken);
    }

    // notificationType/subtype + işlem verisinden abonelik statüsünü belirler.
    private static SubscriptionStatus ComputeStatus(
        AppStoreServerNotification notification,
        AppStoreTransactionInfo transaction,
        DateTime now)
    {
        if (transaction.RevokedAt.HasValue ||
            notification.NotificationType is "REFUND" or "REVOKE")
            return SubscriptionStatus.Revoked;

        if (string.Equals(notification.Subtype, "GRACE_PERIOD", StringComparison.Ordinal))
            return SubscriptionStatus.GracePeriod;

        if (transaction.ExpiresAt.HasValue && transaction.ExpiresAt.Value > now)
            return SubscriptionStatus.Active;

        return SubscriptionStatus.Expired;
    }
}
