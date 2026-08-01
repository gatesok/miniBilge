namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Rozet kontrolü ve ödüllendirme servisi.
/// Her önemli aksiyondan sonra CheckAndAwardAsync çağrılır.
/// </summary>
public interface IBadgeService
{
    /// <summary>
    /// Belirtilen trigger olayına göre rozet koşullarını kontrol eder ve hak kazanılan rozetleri verir.
    /// </summary>
    /// <returns>Yeni kazanılan rozet key'leri (boş olabilir)</returns>
    Task<IReadOnlyList<string>> CheckAndAwardAsync(Guid childProfileId, BadgeTrigger trigger, BadgeTriggerContext? context = null);
}

/// <summary>
/// Rozet kontrolünü tetikleyen olay türleri.
/// </summary>
public enum BadgeTrigger
{
    QuizCompleted,      // Quiz tamamlandı
    StreakUpdated,      // Streak güncellendi
    MatchCompleted,     // Maç bitti
    ProfileCreated,     // Profil oluşturuldu (erken kuş / beta)
}

/// <summary>
/// Trigger'a bağlı ek veri (opsiyonel).
/// </summary>
public class BadgeTriggerContext
{
    /// Quiz tamamlama
    public double? SuccessPercentage { get; set; }  // %100 kontrolü için
    public int? QuizDurationSeconds { get; set; }   // Hız rozeti için
    public int? TopicsCompletedToday { get; set; }  // Çalışkan arı için
    public int? TotalTopicsCompleted { get; set; }  // (Eski) genel konu sayısı
    public string? SubjectName { get; set; }         // Matematik/İngilizce rozetleri için
    public string? EnglishLevel { get; set; }        // CEFR seviyesi (A1..C2), backend'de normalize edilir
    public int? QuestionAnswerSeconds { get; set; }  // Şimşek rozeti için
    /// Yeni quiz: ≥7 doğru, child grade'ine uygun, daha önce geçilmemiş
    public bool IsEligibleNewQuiz { get; set; } = false;

    /// Bu quiz ile ilgili konunun TÜM gerekli seviyeleri tamamlandı mı? (Konu Ustası)
    public bool TopicJustCompleted { get; set; } = false;
    /// Tamamen bitirilmiş matematik konusu sayısı (Sayıların Efendisi)
    public int? MathTopicsCompleted { get; set; }
    /// Tüm A1 İngilizce içeriği tamamlandı mı? (Kelime Avcısı)
    public bool EnglishA1Completed { get; set; } = false;
    /// B1 seviyesine gerçekten ulaşıldı mı? (CEFR Yolcusu)
    public bool EnglishReachedB1 { get; set; } = false;

    /// Streak güncelleme
    public int? CurrentStreak { get; set; }

    /// Maç tamamlama
    public bool? MatchWon { get; set; }
    public int? TotalMatchWins { get; set; }
    public int? ConsecutiveMatchWins { get; set; }

    /// Profil oluşturma: bu profil sistemdeki ilk 100 profilden biri mi? (early_bird)
    public bool IsAmongFirst100 { get; set; } = false;
}
