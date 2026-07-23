namespace MiniBilge.Application.Options;

public sealed class DailyUsageOptions
{
    public const string SectionName = "DailyUsage";

    public int RewardedBonusLimit { get; set; } = 2;
    public Dictionary<string, DailyUsageFeatureLimit> Features { get; set; } =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["adaptive_quiz"] = new() { Free = 2, Premium = 20 },
            ["entertainment"] = new() { Free = 3, Premium = 20 },
            ["adult_challenge"] = new() { Free = 3, Premium = 20 },
            ["live_match"] = new() { Free = 5, Premium = 30 },
        };
}

public sealed class DailyUsageFeatureLimit
{
    public int Free { get; set; }
    public int Premium { get; set; }
}
