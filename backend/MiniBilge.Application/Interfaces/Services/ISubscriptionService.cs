using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Abonelik/entitlement hesaplamasının tek merkezi. "Premium sayılır" kuralı
/// (Active/GracePeriod + süresi dolmamış + silinmemiş) yalnızca burada tanımlıdır.
/// </summary>
public interface ISubscriptionService
{
    /// <summary>
    /// Verilen aboneliklerden premium sayılan (aktif/grace, süresi dolmamış)
    /// en geç biten aboneliği döner; yoksa null.
    /// </summary>
    UserSubscription? GetActiveSubscription(
        IEnumerable<UserSubscription> subscriptions, DateTime? nowUtc = null);

    /// <summary>Kullanıcının premium (aktif entitlement) olup olmadığını döner.</summary>
    bool IsPremium(IEnumerable<UserSubscription> subscriptions, DateTime? nowUtc = null);
}
