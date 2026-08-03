namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// P6-B08: Ebeveyn için aksiyon alınabilir haftalık öneri (zayıf konu, düzenlilik,
/// doğruluk veya olumlu geri bildirim).
/// </summary>
public class RecommendationDto
{
    /// <summary>Öneri türü anahtarı: weak_topic | consistency | accuracy | positive.</summary>
    public string Key { get; set; } = string.Empty;

    /// <summary>Öncelik: 1 (yüksek) .. 3 (düşük).</summary>
    public int Priority { get; set; }

    public string Title { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;

    /// <summary>weak_topic önerisinde ilgili konunun ID'si; diğerlerinde null.</summary>
    public Guid? TopicId { get; set; }
}
