namespace MiniBilge.Application.Interfaces.Services;

public interface INotificationService
{
    /// <summary>
    /// Sends a daily reminder notification to the specified child.
    /// </summary>
    Task SendDailyReminderAsync(Guid childProfileId, string childName);

    /// <summary>
    /// Sends a streak warning notification (streak at risk today).
    /// </summary>
    Task SendStreakWarningAsync(Guid childProfileId, string childName);

    /// <summary>
    /// Sends a push notification to all provided FCM tokens.
    /// </summary>
    Task SendToTokensAsync(IEnumerable<string> tokens, string title, string body,
        IDictionary<string, string>? data = null);
}
