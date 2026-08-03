namespace MiniBilge.Domain.Entities;

public class CardEconomyState
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public int ShardBalance { get; set; }
    public int AttemptsSinceDrop { get; set; }
    public int DuplicatesSinceNew { get; set; }
    public DateOnly DailyDate { get; set; }
    public int DailyCardsEarned { get; set; }
    public DateTime UpdatedAt { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
}
