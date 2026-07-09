using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>Bir seviyedeki tahmin denemesini tutar. Word alanı tekrar önleme için kullanılır.</summary>
public class WordleLevelAttempt : BaseEntity
{
    public Guid      ChildProfileId { get; set; }
    public int       Level          { get; set; }
    public string    Word           { get; set; } = string.Empty;
    public int       WordLength     { get; set; }
    public List<WordleGuess> Guesses { get; set; } = [];
    public bool      Solved         { get; set; } = false;
    public bool      Finished       { get; set; } = false;
    public int       AttemptsUsed   { get; set; } = 0;
    public int       StarsEarned    { get; set; } = 0;
    public bool      Skipped        { get; set; } = false;
    public DateTime? CompletedAt    { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
}
