using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string PasswordHash { get; set; } = string.Empty;
    public UserRole Role { get; set; }
    public bool IsEmailConfirmed { get; set; }
    public DateTime? LastLoginAt { get; set; }
    public bool CanUseOnlineSpeech { get; set; }
    
    // Navigation
    public ParentProfile? ParentProfile { get; set; }
    public ICollection<UserSubscription> Subscriptions { get; set; } = new List<UserSubscription>();
}
