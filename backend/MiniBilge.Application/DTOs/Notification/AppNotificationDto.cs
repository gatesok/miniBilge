namespace MiniBilge.Application.DTOs.Notification;

public class AppNotificationDto
{
    public Guid   Id               { get; set; }
    public string Title            { get; set; } = string.Empty;
    public string Body             { get; set; } = string.Empty;
    public string NotificationType { get; set; } = string.Empty;
    public bool   IsRead           { get; set; }
    public DateTime CreatedAt      { get; set; }
}
