namespace MiniBilge.Application.DTOs.Usage;

public sealed class DailyUsageStatusDto
{
    public string FeatureKey { get; set; } = string.Empty;
    public DateOnly UsageDate { get; set; }
    public bool IsPremium { get; set; }
    public int BaseLimit { get; set; }
    public int UsedCount { get; set; }
    public int RewardedBonusCount { get; set; }
    public int RewardedBonusLimit { get; set; }
    public int Remaining { get; set; }
    public bool Allowed { get; set; }
}
