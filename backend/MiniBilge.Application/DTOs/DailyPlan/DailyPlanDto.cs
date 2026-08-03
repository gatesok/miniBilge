namespace MiniBilge.Application.DTOs.DailyPlan;

/// <summary>"Bugünkü Planım" günlük plan çıktısı.</summary>
public sealed class DailyPlanDto
{
    public Guid Id { get; init; }
    public DateOnly PlanDate { get; init; }
    public string Status { get; init; } = "pending";
    public string Source { get; init; } = "standard";
    public bool IsPremiumPersonalized { get; init; }
    public int TotalItems { get; init; }
    public int CompletedItems { get; init; }
    public DateTime? CompletedAt { get; init; }
    public int RewardStars { get; init; }
    public int RewardPoints { get; init; }
    public bool RewardGranted { get; init; }
    public IReadOnlyList<DailyPlanItemDto> Items { get; init; } = [];
}

/// <summary>Günlük plandaki tek bir aktivite maddesi.</summary>
public sealed class DailyPlanItemDto
{
    public Guid Id { get; init; }
    public int Order { get; init; }
    public string ActivityType { get; init; } = string.Empty;
    public string Title { get; init; } = string.Empty;
    public string? RouteKey { get; init; }
    public int TargetCount { get; init; }
    public bool IsCompleted { get; init; }
    public DateTime? CompletedAt { get; init; }
}
