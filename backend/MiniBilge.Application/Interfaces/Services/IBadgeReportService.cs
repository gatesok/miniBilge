namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Rozet kazanımlarını yönetim/ölçüm amacıyla raporlar: rozet başına kazanım,
/// oyun türü (kategori) bazında kazanım oranı, çocuk/yetişkin dağılımı ve
/// hiç kazanılmayan / aşırı kolay rozet uyarıları.
/// </summary>
public interface IBadgeReportService
{
    /// <param name="tooEasyThreshold">
    /// Bu orandan (0-1) fazla profil tarafından kazanılan rozetler "aşırı kolay"
    /// uyarısı üretir. Varsayılan 0.8 (%80).
    /// </param>
    Task<BadgeAdminReport> GetReportAsync(double tooEasyThreshold = 0.8, CancellationToken cancellationToken = default);
}

/// <summary>Rozet yönetim raporunun tamamı.</summary>
public class BadgeAdminReport
{
    public int TotalProfiles { get; set; }
    public int ChildProfiles { get; set; }
    public int AdultProfiles { get; set; }

    /// <summary>Rozet başına kazanım istatistikleri.</summary>
    public List<BadgeStat> Badges { get; set; } = new();

    /// <summary>Oyun türü (kategori) bazında kazanım oranları.</summary>
    public List<GameTypeStat> GameTypes { get; set; } = new();

    public BadgeReportWarnings Warnings { get; set; } = new();
}

/// <summary>Tek bir rozetin kazanım istatistiği.</summary>
public class BadgeStat
{
    public string Key { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Rarity { get; set; } = string.Empty;

    /// <summary>Rozeti kazanmış benzersiz profil sayısı.</summary>
    public int EarnedCount { get; set; }
    public int ChildEarned { get; set; }
    public int AdultEarned { get; set; }

    /// <summary>Kazanmış profil / toplam profil (0-1).</summary>
    public double EarnRate { get; set; }
}

/// <summary>Oyun türü (kategori) bazında kazanım istatistiği.</summary>
public class GameTypeStat
{
    public string Category { get; set; } = string.Empty;
    public int BadgeCount { get; set; }

    /// <summary>Bu kategorideki toplam (profil × rozet) kazanım adedi.</summary>
    public int TotalEarned { get; set; }

    /// <summary>Bu kategoriden en az bir rozet kazanmış benzersiz profil sayısı.</summary>
    public int ProfilesWithAny { get; set; }

    /// <summary>ProfilesWithAny / toplam profil (0-1).</summary>
    public double EarnRate { get; set; }
}

/// <summary>Yönetim uyarıları.</summary>
public class BadgeReportWarnings
{
    /// <summary>Hiç kazanılmamış aktif rozetlerin key'leri.</summary>
    public List<string> NeverEarned { get; set; } = new();

    /// <summary>Eşiğin üzerinde profil tarafından kazanılan (aşırı kolay) rozetler.</summary>
    public List<string> TooEasy { get; set; } = new();

    public double TooEasyThreshold { get; set; }
}
