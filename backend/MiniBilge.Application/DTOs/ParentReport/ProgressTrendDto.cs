namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// P6-B05: Premium gelişim trendi. Belirtilen gün penceresi (30/90) için toplamlar
/// ve haftalık kırılım.
/// </summary>
public class ProgressTrendDto
{
    public Guid ChildId { get; set; }
    public int Days { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public int ActiveDays { get; set; }
    public int LevelsCompleted { get; set; }
    public int TotalPointsEarned { get; set; }
    public int TotalStarsEarned { get; set; }
    public List<TrendPointDto> WeeklyTrend { get; set; } = new();
}

/// <summary>Trend penceresindeki tek bir haftalık kova.</summary>
public class TrendPointDto
{
    public DateTime WeekStart { get; set; }
    public DateTime WeekEnd { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public int ActiveDays { get; set; }
}
