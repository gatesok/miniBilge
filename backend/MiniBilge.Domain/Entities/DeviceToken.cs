using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class DeviceToken : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public string Token { get; set; } = string.Empty;
    public string Platform { get; set; } = "ios"; // ios | android
    
    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
}
