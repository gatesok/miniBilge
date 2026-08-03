using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Özellik başına kullanım kotası override'ı. Satır yoksa config (DailyUsageOptions) kullanılır.
/// </summary>
public sealed class UsageQuota : BaseEntity
{
    public string FeatureKey { get; set; } = string.Empty;
    public int FreeLimit { get; set; }
    public int PremiumLimit { get; set; }
    public int? RewardedBonusLimit { get; set; }
    public bool IsActive { get; set; } = true;
}
