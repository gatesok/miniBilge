using MiniBilge.Application.DTOs.Profile;

namespace MiniBilge.Application.DTOs.Auth;

public class UserDto
{
    public Guid Id { get; set; }
    public string Email { get; set; } = string.Empty;
    public string Role { get; set; } = string.Empty;
    public bool CanUseOnlineSpeech { get; set; }
    public string ExperienceMode { get; set; } = string.Empty;
    public ParentProfileDto? ParentProfile { get; set; }
}
