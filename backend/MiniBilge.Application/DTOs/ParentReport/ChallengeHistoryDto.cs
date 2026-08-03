namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// Çocuğun meydan okuma geçmişinin kategori bazlı özeti (rakip bilgisi içermez).
/// Yalnızca tamamlanan meydan okumalar dahildir.
/// </summary>
public class ChallengeHistoryDto
{
    public Guid ChildId { get; set; }
    public int TotalCompleted { get; set; }
    public int Won { get; set; }
    public int Lost { get; set; }
    public int Tie { get; set; }
    public List<ChallengeCategoryStatDto> Categories { get; set; } = [];
}

public class ChallengeCategoryStatDto
{
    public string Category { get; set; } = string.Empty;
    public int Played { get; set; }
    public int Won { get; set; }
    public int Lost { get; set; }
    public int Tie { get; set; }

    /// Galibiyet yüzdesi (0-100, played üzerinden).
    public decimal WinRate { get; set; }
}
