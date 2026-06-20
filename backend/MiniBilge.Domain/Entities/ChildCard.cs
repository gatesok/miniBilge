namespace MiniBilge.Domain.Entities;

public class ChildCard
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public Guid CardId { get; set; }
    public int Count { get; set; } = 1;
    public DateTime FirstEarnedAt { get; set; }
    public DateTime LastEarnedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public CollectibleCard Card { get; set; } = null!;
}
