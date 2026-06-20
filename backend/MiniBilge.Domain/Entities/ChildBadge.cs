namespace MiniBilge.Domain.Entities;

public class ChildBadge
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public Guid BadgeId { get; set; }
    public DateTime EarnedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public Badge Badge { get; set; } = null!;
}
