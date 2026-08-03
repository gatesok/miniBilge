using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// P6-B04: Ebeveynin bir çocuk için belirlediği haftalık hedef
/// (haftalık çalışma dakikası ve/veya odaklanılacak konu). Çocuk başına tek satır (upsert).
/// </summary>
public class ParentWeeklyGoal : BaseEntity
{
    public Guid ChildProfileId { get; set; }

    /// <summary>Haftalık hedef çalışma dakikası (opsiyonel).</summary>
    public int? WeeklyStudyMinutesGoal { get; set; }

    /// <summary>Bu hafta odaklanılacak konu (opsiyonel).</summary>
    public Guid? FocusTopicId { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
}
