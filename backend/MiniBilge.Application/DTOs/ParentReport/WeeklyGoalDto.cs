namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// P6-B04: Ebeveynin belirlediği haftalık hedef + bu haftanın ilerlemesi.
/// </summary>
public class WeeklyGoalDto
{
    public Guid ChildId { get; set; }

    /// <summary>Haftalık hedef çalışma dakikası (belirlenmemişse null).</summary>
    public int? WeeklyStudyMinutesGoal { get; set; }

    /// <summary>Odak konu ID'si (belirlenmemişse null).</summary>
    public Guid? FocusTopicId { get; set; }
    public string? FocusTopicName { get; set; }

    // Mevcut hafta (Pazartesi başlangıçlı) ilerleme.
    public DateTime WeekStart { get; set; }
    public DateTime WeekEnd { get; set; }
    public int StudyMinutesThisWeek { get; set; }
    public int QuestionsThisWeek { get; set; }

    /// <summary>Odak konusundaki bu haftaki başarı oranı (0-1); veri yoksa null.</summary>
    public decimal? FocusTopicSuccessRate { get; set; }
}

/// <summary>Haftalık hedef belirleme/güncelleme isteği (upsert).</summary>
public class SetWeeklyGoalRequest
{
    public int? WeeklyStudyMinutesGoal { get; set; }
    public Guid? FocusTopicId { get; set; }
}
