namespace MiniBilge.Application.DTOs.Profile;

public class ChildProfileDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public int Age { get; set; }
    public string GradeLevel { get; set; } = string.Empty;
    public string ProfileType { get; set; } = "Child";
    public string? EnglishLevel { get; set; }
    public string? AvatarImageUrl { get; set; }   // Hesaplanan: preference'a göre fotoğraf veya karakter
    public string? PhotoUrl { get; set; }           // Ham fotoğraf URL'si (kayıtlıysa)
    public bool UseAvatarAsProfile { get; set; }    // true = avatar göster, false = fotoğraf göster
    public int TotalCoins { get; set; }
    public int TotalStars { get; set; }
    /// <summary>0 = Offline (cihaz TTS), 1 = Online (Google TTS)</summary>
    public int PodcastListeningMode { get; set; } = 0;
    /// <summary>Arkadaş davetlerinde paylaşılan 6 karakterli benzersiz kod (MB-XXXXXX).</summary>
    public string FriendCode { get; set; } = string.Empty;
    public bool IsTeacher { get; set; }
}
