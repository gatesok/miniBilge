using MiniBilge.Application.DTOs.ParentReport;

namespace MiniBilge.Application.Interfaces;

public interface IParentReportingService
{
    Task<DailySummaryDto> GetDailySummaryAsync(Guid childId, DateTime date);
    Task<WeeklySummaryDto> GetWeeklySummaryAsync(Guid childId, DateTime weekStart);
    Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId, int topN = 5);
    Task<ActivitySummaryDto> GetActivitySummaryAsync(Guid childId);
}
