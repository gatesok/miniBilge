namespace MiniBilge.Application.DTOs.Flashcard;

public class FlashcardDeckDto
{
    public Guid Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Level { get; set; }
    public Guid? EpisodeId { get; set; }
    public int TotalCards { get; set; }
    public int LearnedCount { get; set; }
}

public class FlashcardDto
{
    public Guid Id { get; set; }
    public Guid DeckId { get; set; }
    public string FrontText { get; set; } = string.Empty;
    public string BackText { get; set; } = string.Empty;
    public string? ExampleSentence { get; set; }
    public string? AudioUrl { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsLearned { get; set; }
    public int ReviewCount { get; set; }
}

public class MarkFlashcardRequest
{
    public Guid ChildProfileId { get; set; }
    public bool IsLearned { get; set; }
}

public class FlashcardSessionResultDto
{
    public Guid DeckId { get; set; }
    public int LearnedCount { get; set; }
    public int TotalCards { get; set; }
    public int StarEarned { get; set; }
    public bool IsFirstCompletion { get; set; }
}
