namespace MiniBilge.Application.Interfaces.Repositories;

/// <summary>Bir oyun sonucunun galibiyet durumu.</summary>
public enum GameOutcome
{
    Win,
    Loss,
    Tie,
}

/// <summary>
/// Bir sonuç uygulandıktan sonra profilin ilgili oyun türü için güncel
/// sayaçlarının anlık görüntüsü. Rozet koşulları bu değerlerden hesaplanır.
/// </summary>
public class GameStatSnapshot
{
    public int TotalPlayed { get; set; }
    public int TotalWon { get; set; }
    public int TotalPerfectWins { get; set; }
    public int CurrentWinStreak { get; set; }
    public int BestWinStreak { get; set; }

    /// Kazanılan (Won > 0) farklı kategori sayısı — çeşitlilik rozetleri için.
    public int DistinctCategoriesWon { get; set; }

    /// Aggregate satırındaki ortalama başarı yüzdesi (eğlence quizi rozetleri için).
    public double AverageSuccessPercentage { get; set; }

    /// Sonucun uygulandığı kategori satırının kendi sayaçları.
    public int CategoryPlayed { get; set; }
    public int CategoryWon { get; set; }
    public double CategoryAverageSuccessPercentage { get; set; }
}

/// <summary>
/// Profil bazlı oyun istatistiklerini (profile_game_stats) günceller ve okur.
/// Meydan okuma, canlı yarış ve eğlence quizi rozetlerinin ortak sayaç altyapısıdır.
/// Not: Bu depo saf artırıcıdır; her olayın yalnızca bir kez işlenmesini
/// çağıran taraf (örn. skor gönderim/durum kilidi ya da idempotency anahtarı) sağlamalıdır.
/// </summary>
public interface IGameStatsRepository
{
    Task<GameStatSnapshot> ApplyResultAsync(
        Guid childProfileId,
        string gameType,
        string categoryKey,
        GameOutcome outcome,
        bool perfectWin,
        int successPercentage,
        string? idempotencyKey = null);

    /// <summary>
    /// Sayaçları değiştirmeden bir oyun türünün (ve opsiyonel kategorinin)
    /// güncel anlık görüntüsünü döndürür. Rozet ilerleme yüzdeleri için kullanılır.
    /// </summary>
    Task<GameStatSnapshot> GetSnapshotAsync(
        Guid childProfileId,
        string gameType,
        string categoryKey = "");

    /// <summary>
    /// Bir oyun türüne ait tüm satırları (aggregate + kategori) döndürür.
    /// Ebeveyn raporunda eğlence quizi kırılımı için kullanılır.
    /// </summary>
    Task<IReadOnlyList<Domain.Entities.ProfileGameStat>> GetStatsForGameTypeAsync(
        Guid childProfileId,
        string gameType);
}
