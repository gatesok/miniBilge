using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public sealed class DailyFeatureUsage : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public string FeatureKey { get; set; } = string.Empty;
    public DateOnly UsageDate { get; set; }
    public int UsedCount { get; set; }
    public int RewardedBonusCount { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
}
