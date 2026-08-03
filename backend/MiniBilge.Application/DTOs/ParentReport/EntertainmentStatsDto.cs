namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// Çocuğun eğlence quizi (GameType='fun') kümülatif istatistikleri.
/// profile_game_stats tablosundan okunur; tarih bazlı değil, toplam sayaçlardır.
/// </summary>
public class EntertainmentStatsDto
{
    public Guid ChildId { get; set; }
    public int TotalPlayed { get; set; }
    public int TotalWon { get; set; }
    public int PerfectWins { get; set; }

    /// Ortalama başarı yüzdesi (0-100).
    public decimal AverageSuccessRate { get; set; }

    public List<EntertainmentCategoryStatDto> Categories { get; set; } = [];
}

public class EntertainmentCategoryStatDto
{
    public string CategoryKey { get; set; } = string.Empty;
    public string CategoryName { get; set; } = string.Empty;
    public int Played { get; set; }
    public int Won { get; set; }

    /// Ortalama başarı yüzdesi (0-100).
    public decimal AverageSuccessRate { get; set; }
}
