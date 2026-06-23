using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Flashcard : BaseEntity
{
    public Guid DeckId { get; set; }
    public string FrontText { get; set; } = string.Empty;
    public string BackText { get; set; } = string.Empty;
    public string? ExampleSentence { get; set; }
    public string? AudioUrl { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public FlashcardDeck Deck { get; set; } = null!;
    public ICollection<FlashcardProgress> Progresses { get; set; } = new List<FlashcardProgress>();
}
