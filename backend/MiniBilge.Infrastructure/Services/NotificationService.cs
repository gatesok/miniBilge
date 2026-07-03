using System.Globalization;
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
    private readonly IAppNotificationRepository _notifRepo;
    private readonly ILogger<NotificationService> _logger;
    private static bool _firebaseAvailable = false;

    public NotificationService(
        IDeviceTokenRepository deviceTokenRepo,
        IAppNotificationRepository notifRepo,
        ILogger<NotificationService> logger)
    {
        _deviceTokenRepo = deviceTokenRepo;
        _notifRepo       = notifRepo;
        _logger          = logger;
        EnsureFirebaseInitialized(logger);
    }

    private static void EnsureFirebaseInitialized(ILogger logger)
    {
        if (_firebaseAvailable) return;
        try
        {
            if (FirebaseApp.DefaultInstance is null)
            {
                FirebaseApp.Create(new AppOptions
                {
                    Credential = GoogleCredential.GetApplicationDefault(),
                    ProjectId  = "minibilge-c89e8",
                });
            }
            _firebaseAvailable = true;
        }
        catch (Exception ex)
        {
            logger.LogWarning(ex, "[FCM] Firebase başlatılamadı, push bildirimler devre dışı.");
        }
    }

    public Task SendDailyReminderAsync(Guid childProfileId, string childName)
        => _SendSingle(childProfileId,
            "Bugünkü görevini yaptın mı? 🎯",
            $"Hadi {childName}, birkaç soru çöz! Zincirini koruyalım 🔥",
            "daily_reminder",
            new Dictionary<string, string> { ["type"] = "daily_reminder" });

    public Task SendStreakWarningAsync(Guid childProfileId, string childName)
        => _SendSingle(childProfileId,
            "Zincirini kaybetme! 🔥",
            $"{childName}, bugün 1 soru çözmen yeterli!",
            "streak_warning",
            new Dictionary<string, string> { ["type"] = "streak_warning" });

    public Task SendFriendRequestNotificationAsync(Guid addresseeId, string requesterName)
        => _SendSingle(addresseeId,
            "Yeni arkadaşlık isteği! 🤝",
            $"{requesterName} sana arkadaşlık isteği gönderdi.",
            "friend_request",
            new Dictionary<string, string> { ["type"] = "friend_request" });

    public Task SendMatchInviteNotificationAsync(Guid inviteeId, string inviterName, Guid invitationId)
        => _SendSingle(inviteeId,
            "Yarış daveti aldın! ⚡",
            $"{inviterName} seni yarışa davet etti!",
            "match_invite",
            new Dictionary<string, string> { ["type"] = "match_invite", ["invitationId"] = invitationId.ToString() });

    public Task SendMatchInviteResponseNotificationAsync(Guid inviterId, string inviteeName, bool accepted)
    {
        var (title, body) = accepted
            ? ("Davet kabul edildi! 🎉", $"{inviteeName} yarış davetini kabul etti!")
            : ("Davet reddedildi 😔",   $"{inviteeName} yarış davetini reddetti.");
        return _SendSingle(inviterId, title, body, "match_invite_response",
            new Dictionary<string, string> { ["type"] = "match_invite_response", ["accepted"] = accepted.ToString().ToLower() });
    }

    public Task SendChallengeReceivedNotificationAsync(Guid challengeeId, string challengerName, Guid challengeId)
        => _SendSingle(challengeeId,
            "⚔️ Meydan Okuma!",
            $"{challengerName} sana meydan okudu — 48 saat içinde yanıtla!",
            "challenge_received",
            new Dictionary<string, string> { ["type"] = "challenge_received", ["challengeId"] = challengeId.ToString() });

    public Task SendChallengeAcceptedNotificationAsync(Guid challengerId, string challengeeName)
        => _SendSingle(challengerId,
            $"✅ {challengeeName} kabul etti!",
            "Soruları çöz ve skoru gör.",
            "challenge_accepted",
            new Dictionary<string, string> { ["type"] = "challenge_accepted" });

    public Task SendChallengeResultNotificationAsync(
        Guid childId, string opponentName, int myScore, int opponentScore, int total)
    {
        string title, body;
        if (myScore > opponentScore)      { title = "🏆 Meydan Okumayı Kazandın!"; body = $"{opponentName}'a karşı {myScore}/{total} yaptın!"; }
        else if (myScore < opponentScore) { title = "😔 Bu sefer olmadı";          body = $"{opponentName} bu meydan okumada seni geçti."; }
        else                              { title = "🤝 Berabere!";                 body = $"{opponentName} ile aynı skoru yaptınız: {myScore}/{total}"; }
        return _SendSingle(childId, title, body, "challenge_result",
            new Dictionary<string, string> { ["type"] = "challenge_result" });
    }

    public Task SendAssignmentCreatedAsync(
        IEnumerable<Guid> memberIds, string classroomName,
        string assignmentTitle, DateTime? dueDate)
    {
        var body = dueDate.HasValue
            ? $"{classroomName} — Son: {dueDate.Value.ToLocalTime().ToString("d MMMM", new CultureInfo("tr-TR"))}"
            : classroomName;
        return _SendMany(memberIds, $"📚 Yeni Ödev: {assignmentTitle}", body, "new_assignment",
            new Dictionary<string, string> { ["type"] = "new_assignment" });
    }

    public Task SendAssignmentDueReminderAsync(
        Guid childProfileId, string assignmentTitle, string classroomName, DateTime dueDate)
    {
        var dateStr = dueDate.ToLocalTime().ToString("d MMMM", new CultureInfo("tr-TR"));
        return _SendSingle(childProfileId,
            "⏰ Ödev yarın son!",
            $"{classroomName} — {assignmentTitle} ödevini {dateStr} tarihine kadar tamamla!",
            "assignment_due_reminder",
            new Dictionary<string, string> { ["type"] = "assignment_due_reminder" });
    }

    public Task SendAssignmentUpdatedAsync(
        IEnumerable<Guid> memberIds, string classroomName, string assignmentTitle)
        => _SendMany(memberIds, "✏️ Ödev güncellendi",
            $"{classroomName} — \"{assignmentTitle}\" ödevi revize edildi.",
            "assignment_updated",
            new Dictionary<string, string> { ["type"] = "assignment_updated" });

    public Task SendAssignmentDeletedAsync(
        IEnumerable<Guid> memberIds, string classroomName, string assignmentTitle)
        => _SendMany(memberIds, "🗑️ Ödev kaldırıldı",
            $"{classroomName} — \"{assignmentTitle}\" ödevi öğretmen tarafından kaldırıldı.",
            "assignment_deleted",
            new Dictionary<string, string> { ["type"] = "assignment_deleted" });

    public Task SendKickedFromClassroomAsync(Guid childProfileId, string classroomName)
        => _SendSingle(childProfileId,
            "🚪 Sınıftan çıkarıldın",
            $"{classroomName} sınıfından çıkarıldın.",
            "kicked_from_classroom",
            new Dictionary<string, string> { ["type"] = "kicked_from_classroom" });

    public Task SendChallengeReminderNotificationAsync(Guid challengeeId, string challengerName, Guid challengeId)
        => _SendSingle(challengeeId,
            "⏰ Meydan okuma seni bekliyor!",
            $"{challengerName} hâlâ cevabını bekliyor. Süre dolmadan oyna!",
            "challenge_reminder",
            new Dictionary<string, string> { ["type"] = "challenge_reminder", ["challengeId"] = challengeId.ToString() });

    // ── Private helpers: send FCM + save to in-app inbox ────────────────────

    private async Task _SendSingle(
        Guid childId, string title, string body, string type,
        IDictionary<string, string>? data = null)
    {
        var tokens = await _deviceTokenRepo.GetTokensByChildIdAsync(childId);
        await SendToTokensAsync(tokens, title, body, data);
        try { await _notifRepo.SaveAsync(childId, title, body, type); }
        catch (Exception ex) { _logger.LogWarning(ex, "[Inbox] Bildirim kaydedilemedi: {Title}", title); }
    }

    private async Task _SendMany(
        IEnumerable<Guid> childIds, string title, string body, string type,
        IDictionary<string, string>? data = null)
    {
        var ids = childIds.ToList();
        if (ids.Count == 0) return;
        var tokens = await _deviceTokenRepo.GetTokensByChildIdsAsync(ids);
        await SendToTokensAsync(tokens, title, body, data);
        try { foreach (var id in ids) await _notifRepo.SaveAsync(id, title, body, type); }
        catch (Exception ex) { _logger.LogWarning(ex, "[Inbox] Bildirimler kaydedilemedi: {Title}", title); }
    }

    public async Task SendToTokensAsync(
        IEnumerable<string> tokens,
        string title,
        string body,
        IDictionary<string, string>? data = null)
    {        if (!_firebaseAvailable)
        {
            _logger.LogWarning("[FCM] Firebase mevcut değil, bildirim atlanıyor: \"{Title}\"", title);
            return;
        }

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
