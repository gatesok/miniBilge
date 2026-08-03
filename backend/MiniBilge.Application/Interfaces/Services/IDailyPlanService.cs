using MiniBilge.Application.DTOs.DailyPlan;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// "Bugünkü Planım" günlük planını yönetir. Bugünün planı yoksa standart plan
/// üretip kalıcılaştırır, varsa mevcut planı döner.
/// </summary>
public interface IDailyPlanService
{
    /// <summary>
    /// Verilen çocuk profili için bugünün planını döner. Plan yoksa üretilip
    /// kaydedilir. Çağıran kullanıcının profile erişim yetkisi doğrulanır.
    /// </summary>
    Task<DailyPlanDto> GetTodayPlanAsync(
        Guid userId, Guid childProfileId, CancellationToken cancellationToken = default);

    /// <summary>
    /// Bir plan maddesini tamamlanmış olarak işaretler ve plan ilerlemesini/durumunu
    /// günceller. Idempotenttir: zaten tamamlanmış madde tekrar çağrılırsa mevcut plan
    /// değişmeden döner. Çağıran kullanıcının profile erişim yetkisi doğrulanır.
    /// </summary>
    Task<DailyPlanDto> CompleteItemAsync(
        Guid userId, Guid childProfileId, Guid itemId,
        CancellationToken cancellationToken = default);
}
