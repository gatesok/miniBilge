namespace MiniBilge.Application.DTOs.Tournament;

/// <summary>P7-M05: Haftalık eğlence turnuvası — bir kategorinin bu haftaki sıralaması.</summary>
public class TournamentWeekDto
{
    public string CategoryKey { get; set; } = string.Empty;
    public string CategoryLabel { get; set; } = string.Empty;
    public string CategoryEmoji { get; set; } = string.Empty;

    /// <summary>Haftanın Pazartesi başlangıcı (Europe/Istanbul).</summary>
    public DateOnly WeekStart { get; set; }

    public List<TournamentLeaderboardEntryDto> Entries { get; set; } = new();

    /// <summary>İstek çocuk profili gönderdiyse ve turnuvaya katıldıysa kendi satırı; aksi halde null.</summary>
    public TournamentLeaderboardEntryDto? Me { get; set; }
}

public class TournamentLeaderboardEntryDto
{
    public Guid ChildProfileId { get; set; }
    public string ChildName { get; set; } = string.Empty;
    public string? AvatarImageUrl { get; set; }
    public int Points { get; set; }
    public int Wins { get; set; }
    public int GamesPlayed { get; set; }
    public int Rank { get; set; }
}

public class TournamentCategoryDto
{
    public string Key { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
}

/// <summary>Bir yetişkin profilinin bu haftaki bir eğlence kategorisindeki doğru/cevaplanan sayacı.</summary>
public sealed record AdultCategoryWeeklyStats(int CorrectCount, int AnsweredCount);
