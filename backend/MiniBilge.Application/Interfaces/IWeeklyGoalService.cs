using MiniBilge.Application.DTOs.ParentReport;

namespace MiniBilge.Application.Interfaces;

/// <summary>
/// P6-B04: Ebeveyn haftalık hedefi (çalışma dakikası + odak konu) yönetimi.
/// </summary>
public interface IWeeklyGoalService
{
    Task<WeeklyGoalDto> GetWeeklyGoalAsync(Guid childId);
    Task<WeeklyGoalDto> SetWeeklyGoalAsync(Guid childId, int? weeklyStudyMinutesGoal, Guid? focusTopicId, string? focusCategoryKey);
}
