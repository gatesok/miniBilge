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

    /// <summary>Yeni ödev atandığında sınıf üyelerine push bildirimi gönderir.</summary>
    Task SendAssignmentCreatedAsync(
        IEnumerable<Guid> memberIds, string classroomName,
        string assignmentTitle, DateTime? dueDate);

    /// <summary>Ödev son tarihi 1 gün kalan tamamlanmamış ödevler için hatırlatma bildirimi gönderir.</summary>
    Task SendAssignmentDueReminderAsync(Guid childProfileId, string assignmentTitle, string classroomName, DateTime dueDate);

    /// <summary>Ödev revize edildiğinde sınıf üyelerine bildirim gönderir.</summary>
    Task SendAssignmentUpdatedAsync(IEnumerable<Guid> memberIds, string classroomName, string assignmentTitle);

    /// <summary>Ödev silindiğinde sınıf üyelerine bildirim gönderir.</summary>
    Task SendAssignmentDeletedAsync(IEnumerable<Guid> memberIds, string classroomName, string assignmentTitle);

    /// <summary>Öğrenci sınıftan çıkarıldığında bildiririm gönderir.</summary>
    Task SendKickedFromClassroomAsync(Guid childProfileId, string classroomName);

    /// <summary>Meydan okuma hatırlatması (challengee'ye — challeger bekliyor).</summary>
    Task SendChallengeReminderNotificationAsync(Guid challengeeId, string challengerName, Guid challengeId);
}
