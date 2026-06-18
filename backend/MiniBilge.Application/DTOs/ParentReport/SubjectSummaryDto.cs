namespace MiniBilge.Application.DTOs.ParentReport;

public class SubjectSummaryDto
{
    public string SubjectName { get; set; } = string.Empty;
    public int TotalQuestions { get; set; }
    public int CorrectAnswers { get; set; }
    public int WrongAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
}
