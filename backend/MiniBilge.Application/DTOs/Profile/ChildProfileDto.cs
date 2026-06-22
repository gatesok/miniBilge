namespace MiniBilge.Application.DTOs.Profile;

public class ChildProfileDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public int Age { get; set; }
    public string GradeLevel { get; set; } = string.Empty;
    public string? EnglishLevel { get; set; }
    public string? AvatarImageUrl { get; set; }
    public int TotalCoins { get; set; }
    public int TotalStars { get; set; }
    /// <summary>0 = Offline (cihaz TTS), 1 = Online (Google TTS)</summary>
    public int PodcastListeningMode { get; set; } = 0;
}
