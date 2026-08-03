namespace MiniBilge.Application.DTOs.ParentReport;

/// <summary>
/// P6-B06: Premium konu bazlı performans metriği (doğruluk, ortalama çözüm süresi,
/// tekrar/çalışma günü) belirtilen gün penceresi için.
/// </summary>
public class TopicPerformanceDto
{
    public Guid TopicId { get; set; }
    public string TopicName { get; set; } = string.Empty;
    public string SubjectName { get; set; } = string.Empty;
    public int TotalAttempts { get; set; }
    public int CorrectAttempts { get; set; }
    public decimal SuccessRate { get; set; } // 0.0 - 1.0

    /// <summary>Solo denemelerin ortalama çözüm süresi (sn). Süre kaydı yoksa null.</summary>
    public double? AverageTimeSeconds { get; set; }

    /// <summary>Bu konunun çalışıldığı farklı gün sayısı (tekrar ölçüsü).</summary>
    public int DistinctDaysPracticed { get; set; }

    public DateTime LastPracticedAt { get; set; }
}
