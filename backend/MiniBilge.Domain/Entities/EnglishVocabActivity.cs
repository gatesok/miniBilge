using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Bir İngilizce kelime quizi tamamlamasının tekil kaydı. Haftalık hedef ve raporlarda
/// çalışma süresi ve çözülen soru sayısına dahil edilebilmesi için süre + soru sayısı
/// burada tutulur (bu oyun AnswerAttempt üretmez). EntertainmentActivity ile aynı mantık.
/// </summary>
public class EnglishVocabActivity : BaseEntity
{
    public Guid ChildProfileId { get; set; }

    /// <summary>Oynanan CEFR seviyesi (A1..C2).</summary>
    public string EnglishLevel { get; set; } = string.Empty;

    /// <summary>Bu oturumdaki toplam soru sayısı.</summary>
    public int QuestionCount { get; set; }

    /// <summary>Doğru cevap sayısı.</summary>
    public int CorrectCount { get; set; }

    /// <summary>Oyunun sürdüğü toplam saniye (istemci ölçümü).</summary>
    public int DurationSeconds { get; set; }

    /// <summary>Tamamlanma zamanı (haftalık pencere sorgusu için).</summary>
    public DateTime CompletedAt { get; set; }

    /// <summary>Aynı sonucun iki kez kaydedilmesini engelleyen istemci anahtarı (opsiyonel).</summary>
    public string? IdempotencyKey { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
}
