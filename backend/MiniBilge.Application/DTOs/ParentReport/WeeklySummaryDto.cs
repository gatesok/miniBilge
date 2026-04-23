namespace MiniBilge.Application.DTOs.ParentReport;

public class WeeklySummaryDto
{
    public Guid ChildId { get; set; }
    public DateTime WeekStart { get; set; }
    public DateTime WeekEnd { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public int WrongAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public int LevelsCompleted { get; set; }
    public int TotalPointsEarned { get; set; }
    public int TotalStarsEarned { get; set; }
    public int ActiveDays { get; set; } // Kaç gün aktif kullanıldı
    public List<DailySummaryDto> DailyBreakdown { get; set; } = new();
}
