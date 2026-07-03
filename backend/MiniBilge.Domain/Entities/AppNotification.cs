using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class AppNotification : BaseEntity
{
    public Guid   ChildProfileId   { get; set; }
    public string Title            { get; set; } = string.Empty;
    public string Body             { get; set; } = string.Empty;
    public string NotificationType { get; set; } = string.Empty;
    public bool   IsRead           { get; set; } = false;

    // Navigation
    public virtual ChildProfile ChildProfile { get; set; } = null!;
}
