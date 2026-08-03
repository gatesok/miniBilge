using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public sealed class GooglePlayNotificationHandler : IGooglePlayNotificationHandler
{
    private const int NotificationRevoked = 12;

    private readonly ApplicationDbContext _db;
    private readonly IGooglePlayPurchaseVerifier _verifier;
    private readonly IEntitlementService _entitlementService;

    public GooglePlayNotificationHandler(
        ApplicationDbContext db,
        IGooglePlayPurchaseVerifier verifier,
        IEntitlementService entitlementService)
    {
        _db = db;
        _verifier = verifier;
        _entitlementService = entitlementService;
    }

    public async Task HandleAsync(
        GooglePlayDeveloperNotification notification,
        string messageId,
        CancellationToken cancellationToken = default)
    {
        // Idempotency: aynı Pub/Sub messageId daha önce işlendiyse hiçbir şey yapma.
        var alreadyProcessed = await _db.PurchaseTransactions.AnyAsync(
            x => x.Provider == SubscriptionProvider.GooglePlay &&
                 x.DedupKey == messageId,
            cancellationToken);
        if (alreadyProcessed)
            return;

        var now = DateTime.UtcNow;

        if (notification.TestNotification != null)
        {
            AppendTransaction(messageId, "TEST", userId: null,
                purchaseToken: null, productId: null, status: null, expiresAt: null, now);
            await _db.SaveChangesAsync(cancellationToken);
            return;
        }

        Guid? userId = null;

        if (notification.SubscriptionNotification is { PurchaseToken: { Length: > 0 } } sub)
        {
            userId = await HandleSubscriptionAsync(sub, messageId, now, cancellationToken);
        }
        else if (notification.VoidedPurchaseNotification is { PurchaseToken: { Length: > 0 } } voided)
        {
            userId = await HandleVoidedAsync(voided, messageId, now, cancellationToken);
        }
        else
        {
            // Desteklenmeyen bildirim tipi (ör. one-time product): yalnızca denetim kaydı.
            AppendTransaction(messageId, "UNHANDLED", userId: null,
                purchaseToken: null, productId: null, status: null, expiresAt: null, now);
        }

        await _db.SaveChangesAsync(cancellationToken);

        if (userId.HasValue)
            _entitlementService.Invalidate(userId.Value);
    }

    private async Task<Guid?> HandleSubscriptionAsync(
        GooglePlaySubscriptionNotification sub,
        string messageId,
        DateTime now,
        CancellationToken cancellationToken)
    {
        var verified = await _verifier.VerifyAsync(sub.PurchaseToken!, cancellationToken);

        Guid? userId = Guid.TryParse(verified.ObfuscatedExternalAccountId, out var parsed)
            ? parsed
            : null;
        var status = MapStatus(sub.NotificationType, verified.SubscriptionState, verified.ExpiresAt, now);

        var subscription = userId.HasValue
            ? await _db.UserSubscriptions.SingleOrDefaultAsync(
                x => x.Provider == SubscriptionProvider.GooglePlay && x.UserId == userId.Value,
                cancellationToken)
            : await _db.UserSubscriptions.SingleOrDefaultAsync(
                x => x.Provider == SubscriptionProvider.GooglePlay &&
                     x.OriginalTransactionId == sub.PurchaseToken,
                cancellationToken);

        if (subscription == null && userId.HasValue)
        {
            subscription = new UserSubscription
            {
                Id = Guid.NewGuid(),
                UserId = userId.Value,
                Provider = SubscriptionProvider.GooglePlay,
                OriginalTransactionId = sub.PurchaseToken!,
                PurchasedAt = now,
                CreatedAt = now,
            };
            _db.UserSubscriptions.Add(subscription);
        }

        if (subscription != null)
        {
            userId ??= subscription.UserId;
            subscription.OriginalTransactionId = sub.PurchaseToken!;
            subscription.ProductId = verified.ProductId.Length > 0
                ? verified.ProductId
                : sub.SubscriptionId ?? subscription.ProductId;
            subscription.Environment = verified.IsTest ? "Sandbox" : "Production";
            subscription.ExpiresAt = verified.ExpiresAt ?? subscription.ExpiresAt;
            subscription.RevokedAt = status == SubscriptionStatus.Revoked ? now : null;
            subscription.Status = status;
            subscription.LastVerifiedAt = now;
            subscription.UpdatedAt = now;
        }

        AppendTransaction(
            messageId,
            $"SUBSCRIPTION:{sub.NotificationType}",
            userId,
            sub.PurchaseToken,
            subscription?.ProductId ?? verified.ProductId,
            status,
            verified.ExpiresAt,
            now);

        return userId;
    }

    private async Task<Guid?> HandleVoidedAsync(
        GooglePlayVoidedPurchaseNotification voided,
        string messageId,
        DateTime now,
        CancellationToken cancellationToken)
    {
        var subscription = await _db.UserSubscriptions.SingleOrDefaultAsync(
            x => x.Provider == SubscriptionProvider.GooglePlay &&
                 x.OriginalTransactionId == voided.PurchaseToken,
            cancellationToken);

        Guid? userId = subscription?.UserId;
        if (subscription != null)
        {
            subscription.Status = SubscriptionStatus.Revoked;
            subscription.RevokedAt = now;
            subscription.LastVerifiedAt = now;
            subscription.UpdatedAt = now;
        }

        AppendTransaction(
            messageId,
            "VOIDED",
            userId,
            voided.PurchaseToken,
            subscription?.ProductId,
            SubscriptionStatus.Revoked,
            expiresAt: null,
            now);

        return userId;
    }

    private void AppendTransaction(
        string messageId,
        string notificationType,
        Guid? userId,
        string? purchaseToken,
        string? productId,
        SubscriptionStatus? status,
        DateTime? expiresAt,
        DateTime now)
    {
        _db.PurchaseTransactions.Add(new PurchaseTransaction
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Provider = SubscriptionProvider.GooglePlay,
            DedupKey = messageId,
            Source = "play_rtdn",
            NotificationType = notificationType,
            OriginalTransactionId = purchaseToken,
            TransactionId = purchaseToken,
            ProductId = productId,
            Environment = "Production",
            Status = status,
            ExpiresAt = expiresAt,
            ProcessedAt = now,
            CreatedAt = now,
        });
    }

    // notificationType + Play API subscriptionState'ten abonelik statüsünü belirler.
    private static SubscriptionStatus MapStatus(
        int notificationType,
        string state,
        DateTime? expiresAt,
        DateTime now)
    {
        if (notificationType == NotificationRevoked)
            return SubscriptionStatus.Revoked;

        return state switch
        {
            "SUBSCRIPTION_STATE_ACTIVE" => SubscriptionStatus.Active,
            "SUBSCRIPTION_STATE_IN_GRACE_PERIOD" => SubscriptionStatus.GracePeriod,
            "SUBSCRIPTION_STATE_CANCELED" =>
                expiresAt.HasValue && expiresAt.Value > now
                    ? SubscriptionStatus.Active
                    : SubscriptionStatus.Expired,
            "SUBSCRIPTION_STATE_PENDING" => SubscriptionStatus.Pending,
            "SUBSCRIPTION_STATE_ON_HOLD" => SubscriptionStatus.Expired,
            "SUBSCRIPTION_STATE_PAUSED" => SubscriptionStatus.Expired,
            "SUBSCRIPTION_STATE_EXPIRED" => SubscriptionStatus.Expired,
            _ => expiresAt.HasValue && expiresAt.Value > now
                ? SubscriptionStatus.Active
                : SubscriptionStatus.Expired,
        };
    }
}
