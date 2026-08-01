using System.Diagnostics.Metrics;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Rozet değerlendirme metrikleri. OpenTelemetry ile dışa aktarılabilir.
/// </summary>
public static class BadgeMetrics
{
    public const string MeterName = "MiniBilge.Badges";

    private static readonly Meter Meter = new(MeterName, "1.0.0");

    /// <summary>Kazandırılan rozet sayısı (badge etiketiyle).</summary>
    public static readonly Counter<long> Awarded =
        Meter.CreateCounter<long>("badge.awarded", description: "Kazandırılan rozet sayısı");

    /// <summary>Rozet değerlendirme sırasında yutulan hata sayısı.</summary>
    public static readonly Counter<long> EvaluationErrors =
        Meter.CreateCounter<long>("badge.evaluation_errors", description: "Rozet değerlendirme hatası sayısı");
}
