namespace MiniBilge.Application.DTOs.Leaderboard;

public class LeaderboardEntryDto
{
    public Guid ChildProfileId { get; set; }
    public string ChildName { get; set; } = string.Empty;
    public string? AvatarImageUrl { get; set; }
    public int TotalCoins { get; set; }   // Kalan bakiye (mağaza için)
    public int TotalScore { get; set; }   // Toplam kazanılan puan (sıralama için)
    public int TotalStars { get; set; }
    public int Rank { get; set; }
    public string GradeLevel { get; set; } = string.Empty;
    public string ProfileType { get; set; } = "Child";
    public int Wins { get; set; }
    public int GamesPlayed { get; set; }
}
