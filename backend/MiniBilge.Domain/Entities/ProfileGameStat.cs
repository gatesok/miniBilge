using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Profil bazında oyun türü (meydan okuma, canlı yarış, eğlence quizi) istatistiklerini
/// kalıcı olarak tutar. Rozet koşulları istemci sayaçlarına güvenmeden bu tablodan hesaplanır.
///
/// Her profil için:
///   - <see cref="CategoryKey"/> == "" olan satır o oyun türünün TOPLAM (aggregate) sayaçlarıdır
///     ve seri bilgisini de bu satır tutar.
///   - <see cref="CategoryKey"/> dolu satırlar kategori bazlı sayaçlardır (çeşitlilik rozetleri için).
/// </summary>
public class ProfileGameStat : BaseEntity
{
    public Guid ChildProfileId { get; set; }

    /// 'challenge' | 'live_match' | 'fun'
    public string GameType { get; set; } = string.Empty;

    /// "" = oyun türü toplamı; dolu = kategori bazlı satır (ör. 'sinema', 'ingilizce', 'Matematik').
    public string CategoryKey { get; set; } = string.Empty;

    public int Played { get; set; }
    public int Won { get; set; }
    public int Lost { get; set; }
    public int Tie { get; set; }

    /// Tüm soruları doğru cevaplayarak (tam puan) kazanılan oyun sayısı.
    public int PerfectWins { get; set; }

    /// Yalnızca aggregate satırında (CategoryKey == "") anlamlıdır.
    public int CurrentWinStreak { get; set; }
    public int BestWinStreak { get; set; }

    /// Ortalama başarı hesaplayabilmek için başarı yüzdelerinin toplamı (eğlence quizi).
    public int SuccessPercentageSum { get; set; }

    public DateTime? LastResultAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
}
