using MiniBilge.Application.DTOs.Premium;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Doğrulanmış App Store bildirimini işler: user_subscriptions'ı günceller ve
/// purchase_transactions'a idempotent (notificationUUID) kaydeder.
/// </summary>
public interface IAppStoreNotificationHandler
{
    Task HandleAsync(
        AppStoreServerNotification notification,
        CancellationToken cancellationToken = default);
}
