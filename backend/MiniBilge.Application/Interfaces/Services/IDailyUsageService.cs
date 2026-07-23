using MiniBilge.Application.DTOs.Usage;

namespace MiniBilge.Application.Interfaces.Services;

public interface IDailyUsageService
{
    Task<DailyUsageStatusDto> GetStatusAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default);

    Task<DailyUsageStatusDto> ConsumeAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default);

    Task<DailyUsageStatusDto> GrantRewardedBonusAsync(
        Guid userId,
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken = default);
}
