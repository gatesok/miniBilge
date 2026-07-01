namespace MiniBilge.Application.Interfaces.Services;

public interface INotificationService
{
    /// <summary>Sends a daily reminder notification to the specified child.</summary>
    Task SendDailyReminderAsync(Guid childProfileId, string childName);

    /// <summary>Sends a streak warning notification (streak at risk today).</summary>
    Task SendStreakWarningAsync(Guid childProfileId, string childName);

    /// <summary>Sends a push notification to all provided FCM tokens.</summary>
    Task SendToTokensAsync(IEnumerable<string> tokens, string title, string body,
        IDictionary<string, string>? data = null);

    /// <summary>Arkadaşlık isteği push bildirimi.</summary>
    Task SendFriendRequestNotificationAsync(Guid addresseeId, string requesterName);

    /// <summary>Yarış daveti push bildirimi.</summary>
    Task SendMatchInviteNotificationAsync(Guid inviteeId, string inviterName, Guid invitationId);

    /// <summary>Yarış daveti yanıtı push bildirimi.</summary>
    Task SendMatchInviteResponseNotificationAsync(Guid inviterId, string inviteeName, bool accepted);

    /// <summary>Asenkron meydan okuma geldi bildirimi (challengee'ye).</summary>
    Task SendChallengeReceivedNotificationAsync(Guid challengeeId, string challengerName, Guid challengeId);

    /// <summary>Meydan okuma kabul edildi bildirimi (challenger'a).</summary>
    Task SendChallengeAcceptedNotificationAsync(Guid challengerId, string challengeeName);

    /// <summary>Meydan okuma sonucu bildirimi (her iki tarafa ayrı ayrı).</summary>
    Task SendChallengeResultNotificationAsync(Guid childId, string opponentName, int myScore, int opponentScore, int total);
}
