using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class FlashcardProgress : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public Guid FlashcardId { get; set; }
    public bool IsLearned { get; set; } = false;
    public int ReviewCount { get; set; } = 0;
    public DateTime? LastReviewedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public Flashcard Flashcard { get; set; } = null!;
}
