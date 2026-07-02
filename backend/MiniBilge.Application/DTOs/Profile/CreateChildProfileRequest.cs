namespace MiniBilge.Application.DTOs.Profile;

public class CreateChildProfileRequest
{
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public int GradeLevel { get; set; }
    public int? EnglishLevel { get; set; }
    public string? AvatarImageUrl { get; set; }
    /// <summary>0 = Offline, 1 = Online. Belirtilmezse 0 (Offline) kullanılır.</summary>
    public int PodcastListeningMode { get; set; } = 0;
    public bool IsTeacher { get; set; } = false;
}
