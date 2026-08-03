using MiniBilge.Application.DTOs.ParentReport;

namespace MiniBilge.Application.Interfaces;

public interface IParentReportingService
{
    Task<DailySummaryDto> GetDailySummaryAsync(Guid childId, DateTime date);
    Task<WeeklySummaryDto> GetWeeklySummaryAsync(Guid childId, DateTime weekStart);
    Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId, int topN = 5);
    Task<ActivitySummaryDto> GetActivitySummaryAsync(Guid childId);

    // P6-B05: 30/90 günlük gelişim trendi (premium).
    Task<ProgressTrendDto> GetProgressTrendAsync(Guid childId, int days);

    // P6-B06: konu bazlı performans metrikleri (premium).
    Task<List<TopicPerformanceDto>> GetTopicPerformanceAsync(Guid childId, int days);

    // P6-B08: aksiyon alınabilir haftalık öneriler (premium).
    Task<List<RecommendationDto>> GetWeeklyRecommendationsAsync(Guid childId);

    // P6-B07: ebeveynin tüm çocuklarını kapsayan aile özeti (premium).
    Task<FamilySummaryDto> GetFamilySummaryAsync(
        IReadOnlyList<(Guid ChildId, string ChildName)> children, int days);

    // Eğlence quizi (GameType='fun') kümülatif istatistikleri (premium).
    Task<EntertainmentStatsDto> GetEntertainmentStatsAsync(Guid childId);

    // Meydan okuma geçmişi (rakip, kategori, sonuç) (premium).
    Task<ChallengeHistoryDto> GetChallengeHistoryAsync(Guid childId);
}
