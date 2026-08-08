namespace MiniBilge.Application.Options;

public sealed class DailyUsageOptions
{
    public const string SectionName = "DailyUsage";

    public int RewardedBonusLimit { get; set; } = 0;
    public Dictionary<string, DailyUsageFeatureLimit> Features { get; set; } =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["adaptive_quiz"] = new() { Free = 1, Premium = 10 },
            ["standard_quiz"] = new() { Free = 5, Premium = -1 },
            ["entertainment"] = new() { Free = 3, Premium = 20 },
            ["adult_challenge"] = new() { Free = 3, Premium = 20 },
            ["live_match"] = new() { Free = 5, Premium = 30 },
            ["ai_english"] = new() { Free = 2, Premium = 2 },
            ["ai_flashcards"] = new() { Free = 0, Premium = 3 },
            ["ai_writing"] = new() { Free = 0, Premium = 3 },
            ["ai_vocab_challenge"] = new() { Free = 0, Premium = 3 },
            ["ai_roleplay"] = new() { Free = 0, Premium = 3 },
            ["ai_pronunciation"] = new() { Free = 0, Premium = 3 },
        };
}

public sealed class DailyUsageFeatureLimit
{
    /// <summary>-1 sınırsız kullanım anlamına gelir.</summary>
    public int Free { get; set; }
    public int Premium { get; set; }
}
