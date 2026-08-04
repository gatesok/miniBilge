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

    /// <summary>
    /// Daha önce tüketilmiş bir hakkı geri verir (telafi). Kullanım kaydı yoksa
    /// veya sayaç zaten 0 ise sessizce mevcut durumu döner. Meydan okuma oluşturma
    /// teknik nedenle başarısız olduğunda hakkın kaybedilmemesi için kullanılır.
    /// </summary>
    Task<DailyUsageStatusDto> RefundAsync(
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
