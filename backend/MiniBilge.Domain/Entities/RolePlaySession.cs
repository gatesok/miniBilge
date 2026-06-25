namespace MiniBilge.Domain.Entities;

public class RolePlaySession
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public string ScenarioKey { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public string Status { get; set; } = "active";          // "active" | "completed"
    public int TurnCount { get; set; } = 0;
    public int? TotalScore { get; set; }
    public string? FinalFeedback { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? CompletedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public ICollection<RolePlayTurn> Turns { get; set; } = new List<RolePlayTurn>();
}
