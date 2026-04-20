namespace MiniBilge.Application.DTOs.Profile;

public class CreateChildProfileRequest
{
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public int GradeLevel { get; set; }
    public string? AvatarImageUrl { get; set; }
}
