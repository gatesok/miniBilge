namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// Çocuğun meydan okuma geçmişi (rakip, kategori, sonuç). Yalnızca tamamlanan
/// meydan okumalar dahildir. Rakip adı çocuğa uygulama içinde zaten gösterilir.
/// </summary>
public class ChallengeHistoryDto
{
    public Guid ChildId { get; set; }
    public int TotalCompleted { get; set; }
    public int Won { get; set; }
    public int Lost { get; set; }
    public int Tie { get; set; }
    public List<ChallengeHistoryItemDto> Items { get; set; } = [];
}

public class ChallengeHistoryItemDto
{
    public Guid Id { get; set; }
    public string OpponentName { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;

    /// "won" | "lost" | "tie"
    public string Result { get; set; } = string.Empty;

    public int MyScore { get; set; }
    public int OpponentScore { get; set; }
    public int TotalQuestions { get; set; }
    public DateTime PlayedAt { get; set; }
}
