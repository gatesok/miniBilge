using FirebaseAdmin;
using FirebaseAdmin.Messaging;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Push notification service using Firebase Cloud Messaging (FCM) via Firebase Admin SDK.
/// On Cloud Run uses Application Default Credentials (ADC) automatically.
/// For local dev set GOOGLE_APPLICATION_CREDENTIALS env var to service account JSON path.
/// </summary>
public class NotificationService : INotificationService
{
    private readonly IDeviceTokenRepository _deviceTokenRepo;
    private readonly ILogger<NotificationService> _logger;

    public NotificationService(
        IDeviceTokenRepository deviceTokenRepo,
        ILogger<NotificationService> logger)
    {
        _deviceTokenRepo = deviceTokenRepo;
        _logger = logger;
        EnsureFirebaseInitialized();
    }

    private static void EnsureFirebaseInitialized()
    {
        if (FirebaseApp.DefaultInstance is null)
        {
            FirebaseApp.Create(new AppOptions
            {
                Credential = GoogleCredential.GetApplicationDefault(),
            });
        }
    }

    public async Task SendDailyReminderAsync(Guid childProfileId, string childName)
    {
        var tokens = await _deviceTokenRepo.GetTokensByChildIdAsync(childProfileId);
        await SendToTokensAsync(
            tokens,
            title: "Bugünkü görevini yaptın mı? 🎯",
            body: $"Hadi {childName}, birkaç soru çöz! Zincirini koruyalım 🔥",
            data: new Dictionary<string, string> { ["type"] = "daily_reminder" });
    }

    public async Task SendStreakWarningAsync(Guid childProfileId, string childName)
    {
        var tokens = await _deviceTokenRepo.GetTokensByChildIdAsync(childProfileId);
        await SendToTokensAsync(
            tokens,
            title: "Zincirini kaybetme! 🔥",
            body: $"{childName}, bugün 1 soru çözmen yeterli!",
            data: new Dictionary<string, string> { ["type"] = "streak_warning" });
    }

    public async Task SendToTokensAsync(
        IEnumerable<string> tokens,
        string title,
        string body,
        IDictionary<string, string>? data = null)
    {
        var tokenList = tokens.ToList();
        if (tokenList.Count == 0) return;

        // FCM allows max 500 tokens per multicast message
        const int batchSize = 500;
        var batches = tokenList
            .Select((t, i) => new { t, i })
            .GroupBy(x => x.i / batchSize)
            .Select(g => g.Select(x => x.t).ToList());

        foreach (var batch in batches)
        {
            var message = new MulticastMessage
            {
                Tokens = batch,
                Notification = new Notification
                {
                    Title = title,
                    Body = body,
                },
                Apns = new ApnsConfig
                {
                    Aps = new Aps
                    {
                        Sound = "default",
                        Badge = 1,
                    },
                },
                Data = data?.ToDictionary(kv => kv.Key, kv => kv.Value),
            };

            try
            {
                var response = await FirebaseMessaging.DefaultInstance
                    .SendEachForMulticastAsync(message);

                _logger.LogInformation(
                    "[FCM] Sent \"{Title}\" — success: {Success}, failure: {Failure}",
                    title, response.SuccessCount, response.FailureCount);

                // Log individual failures for debugging
                for (int i = 0; i < response.Responses.Count; i++)
                {
                    if (!response.Responses[i].IsSuccess)
                    {
                        _logger.LogWarning(
                            "[FCM] Token failed: {Token} — {Error}",
                            batch[i][..Math.Min(20, batch[i].Length)],
                            response.Responses[i].Exception?.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[FCM] Multicast send failed for \"{Title}\"", title);
            }
        }
    }
}
