namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Mevcut profillere Sprint 2 rozet ailelerini (meydan okuma, canlı yarış,
/// eğlence quizi) geriye dönük veren tek seferlik, tekrar çalıştırılabilir servis.
///
/// Politika gereği yalnızca güncel toplam sayaçlardan güvenle türetilebilen
/// "toplam adet", "çeşitlilik" ve "ustalık" rozetleri backfill edilir; olay
/// sırası gerektiren seri, kusursuz galibiyet ve geri dönüş rozetleri hariç tutulur.
///
/// <see cref="RunAsync"/> önce <c>apply=false</c> ile rapor modunda çalıştırılarak
/// kaç profile hangi rozetin verileceği görülür; onaydan sonra <c>apply=true</c> ile
/// idempotent şekilde gerçek kayıtlar oluşturulur.
/// </summary>
public interface IBadgeBackfillService
{
    Task<BadgeBackfillReport> RunAsync(bool apply, CancellationToken cancellationToken = default);
}

/// <summary>Backfill çalışmasının özet sonucu.</summary>
public class BadgeBackfillReport
{
    /// <summary>true ise kayıtlar yazıldı; false ise yalnızca rapor (dry-run).</summary>
    public bool Applied { get; set; }

    /// <summary>Taranan (silinmemiş) profil sayısı.</summary>
    public int ProfilesScanned { get; set; }

    /// <summary>Verilen (veya rapor modunda verilecek) toplam rozet sayısı.</summary>
    public int TotalAwarded { get; set; }

    /// <summary>Rozet başına uygun (henüz kazanılmamış) profil sayısı.</summary>
    public List<BadgeBackfillItem> Badges { get; set; } = new();
}

/// <summary>Tek bir rozet için backfill kalemi.</summary>
public class BadgeBackfillItem
{
    public string BadgeKey { get; set; } = string.Empty;

    /// <summary>Koşulu sağlayan ve rozeti henüz kazanmamış profil sayısı.</summary>
    public int EligibleProfiles { get; set; }
}
