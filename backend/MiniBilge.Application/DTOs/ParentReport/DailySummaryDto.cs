namespace MiniBilge.Application.DTOs.ParentReport;

public class DailySummaryDto
{
    public Guid ChildId { get; set; }
    public DateTime Date { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public int WrongAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public int LevelsCompleted { get; set; }
    public int PointsEarned { get; set; }
    public int StarsEarned { get; set; }
}
