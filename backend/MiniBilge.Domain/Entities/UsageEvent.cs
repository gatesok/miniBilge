using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Kullanım hakkı tüketimi ve ödül olaylarının append-only kaydı (audit/analiz/replay koruması).
/// </summary>
public sealed class UsageEvent : BaseEntity
{
    public Guid? UserId { get; set; }
    public Guid ChildProfileId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public string EventType { get; set; } = string.Empty;
    public DateOnly UsageDate { get; set; }
    public bool IsPremium { get; set; }
    public int UsedCountAfter { get; set; }
    public string? IdempotencyKey { get; set; }
}
