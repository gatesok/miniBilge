using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Çocuk profilinin yaş/sınıf/İngilizce seviyesine göre "Bugünkü Planım" için
/// standart (premium olmayan) günlük planı üretir. Yalnızca bellek içinde plan
/// nesnesi kurar; kalıcılaştırma çağıran endpoint'in sorumluluğundadır.
/// </summary>
public interface IDailyPlanGenerator
{
    /// <summary>
    /// Verilen profil ve tarih için standart bir <see cref="DailyPlan"/> (maddeleriyle
    /// birlikte) üretir. Id'ler atanır, TotalItems doldurulur, Status = Pending olur.
    /// </summary>
    DailyPlan Generate(ChildProfile profile, DateOnly planDate);

    /// <summary>
    /// Standart üretim (eksik içerik / servis hatası) başarısız olduğunda kullanılacak,
    /// dış içeriğe bağımlı olmayan minimum güvenli planı (Source = "fallback") üretir.
    /// </summary>
    DailyPlan GenerateFallback(ChildProfile profile, DateOnly planDate);
}
