using MiniBilge.Application.DTOs.Premium;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Google Play RTDN bildirimini işler: satın almayı Play API ile doğrular,
/// user_subscriptions'ı günceller ve purchase_transactions'a idempotent
/// (Pub/Sub messageId) kaydeder.
/// </summary>
public interface IGooglePlayNotificationHandler
{
    Task HandleAsync(
        GooglePlayDeveloperNotification notification,
        string messageId,
        CancellationToken cancellationToken = default);
}
