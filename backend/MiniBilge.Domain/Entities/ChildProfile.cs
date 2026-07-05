using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class ChildProfile : BaseEntity
{
    public Guid ParentProfileId { get; set; }
    public string Name { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public GradeLevel GradeLevel { get; set; }
    public EnglishLevel? EnglishLevel { get; set; }
    public string? AvatarImageUrl    { get; set; } // Karakter key (robot, male_person vb.)
    public string? PhotoUrl           { get; set; } // Yüklenen profil fotoğrafı URL'si
    /// <summary>true = avatar göster, false = fotoğraf göster (fotoğraf varsa)</summary>
    public bool    UseAvatarAsProfile { get; set; } = false;
    public int TotalCoins { get; set; } = 0;
    public int TotalStars { get; set; } = 0;
    public PodcastListeningMode PodcastListeningMode { get; set; } = PodcastListeningMode.Offline;
    public string FriendCode { get; set; } = string.Empty;
    public bool IsTeacher { get; set; } = false;

    // Navigation
    public ParentProfile ParentProfile { get; set; } = null!;
    public ICollection<Friendship> FriendshipsAsRequester { get; set; } = new List<Friendship>();
    public ICollection<Friendship> FriendshipsAsAddressee { get; set; } = new List<Friendship>();
}
