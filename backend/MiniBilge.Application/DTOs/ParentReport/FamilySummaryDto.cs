namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// P6-B07: Ebeveynin tüm çocuklarını kapsayan aile özeti (belirtilen gün penceresi).
/// </summary>
public class FamilySummaryDto
{
    public int Days { get; set; }
    public DateTime PeriodStart { get; set; }
    public DateTime PeriodEnd { get; set; }
    public int TotalChildren { get; set; }
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public List<FamilyChildSummaryDto> Children { get; set; } = new();
}

/// <summary>Aile özetindeki tek bir çocuğun kompakt özeti.</summary>
public class FamilyChildSummaryDto
{
    public Guid ChildId { get; set; }
    public string ChildName { get; set; } = string.Empty;
    public int TotalQuestionsAnswered { get; set; }
    public int CorrectAnswers { get; set; }
    public decimal CorrectAnswerRate { get; set; } // 0.0 - 1.0
    public int ActiveDays { get; set; }
    public int LevelsCompleted { get; set; }
    public int TotalStarsEarned { get; set; }
}
