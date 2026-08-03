using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// P7-M05: Yetişkin modu haftalık eğlence turnuvası kaydı. Her (çocuk profili, hafta başlangıcı,
/// eğlence kategorisi) için tek satır; solo eğlence quizleri ve eğlence meydan okumalarından
/// gelen puanlar bu satıra toplanır (upsert). Ödül yok, yalnızca sıralama (V1).
/// </summary>
public class AdultTournamentEntry : BaseEntity
{
    public Guid ChildProfileId { get; set; }

    /// <summary>Haftanın Pazartesi başlangıcı (Europe/Istanbul).</summary>
    public DateOnly WeekStart { get; set; }

    /// <summary>Eğlence kategori anahtarı (spor, genel_kultur, muzik, sinema, teknoloji, sanat).</summary>
    public string CategoryKey { get; set; } = string.Empty;

    public int Points { get; set; }
    public int Wins { get; set; }
    public int GamesPlayed { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
}
