namespace MiniBilge.Domain.Entities;

public class CardDropLog
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public Guid CardId { get; set; }
    public string Source { get; set; } = string.Empty; // 'quiz_complete', 'correct_answer'
    public DateTime EarnedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public CollectibleCard Card { get; set; } = null!;
}
