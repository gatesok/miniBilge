using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public sealed class AiUsageEvent : BaseEntity
{
    public Guid? ChildProfileId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public string Provider { get; set; } = "openai";
    public string Model { get; set; } = string.Empty;
    public int? InputTokens { get; set; }
    public int? OutputTokens { get; set; }
    public decimal? EstimatedCostUsd { get; set; }
    public long DurationMs { get; set; }
    public bool Success { get; set; }
    public string? ErrorCode { get; set; }
    public string? CorrelationId { get; set; }

    public ChildProfile? ChildProfile { get; set; }
}
