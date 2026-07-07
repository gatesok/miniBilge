using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>Bir kullanıcının belirli bir gün için tahminleri ve sonucu.</summary>
public class WordGuessResult : BaseEntity
{
    public Guid       ChildProfileId { get; set; }
    public DateOnly   Date           { get; set; }
    public Guid       WordPoolId     { get; set; }
    public List<WordleGuess> Guesses { get; set; } = [];
    public bool       Solved         { get; set; } = false;
    public int        AttemptsUsed   { get; set; } = 0;
    public DateTime?  CompletedAt    { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public WordPool     WordPool     { get; set; } = null!;
}

/// <summary>Tek bir tahmin satırı — JSONB içinde saklanır.</summary>
public class WordleGuess
{
    public string   Guess   { get; set; } = string.Empty;
    /// <summary>"correct" | "present" | "absent" — her harf için.</summary>
    public string[] Pattern { get; set; } = [];
}
