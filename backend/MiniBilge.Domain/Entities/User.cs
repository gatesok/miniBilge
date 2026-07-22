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
    public ExperienceMode ExperienceMode { get; set; } = ExperienceMode.Family;
    public bool HasSelectedExperienceMode { get; set; } = true;
    
    // Navigation
    public ParentProfile? ParentProfile { get; set; }
}
