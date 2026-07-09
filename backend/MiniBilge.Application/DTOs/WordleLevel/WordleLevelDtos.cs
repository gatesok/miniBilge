namespace MiniBilge.Application.DTOs.WordleLevel;

// ── Yanıt DTO'ları ────────────────────────────────────────────────────────────

public class WordleLevelStateDto
{
    public int    CurrentLevel  { get; set; }
    public int    HighestLevel  { get; set; }
    public int    WordLength    { get; set; }
    public int    MaxAttempts   { get; set; }
    public int    AttemptsUsed  { get; set; }
    public string? Hint         { get; set; }
    public bool   Solved        { get; set; }
    public bool   Finished      { get; set; }
    public bool   Skipped       { get; set; }
    public int    SkipTickets   { get; set; }
    public int    StarsEarned   { get; set; }
    public List<WordleLevelGuessDto> Guesses { get; set; } = [];
}

public class WordleLevelGuessDto
{
    public string   Guess   { get; set; } = string.Empty;
    public string[] Pattern { get; set; } = [];
}

public class WordleLevelSubmitRequest
{
    public string Guess { get; set; } = string.Empty;
}

public class WordleLevelSubmitResponse
{
    public string[] Pattern      { get; set; } = [];
    public bool     Solved       { get; set; }
    public bool     Finished     { get; set; }
    public int      AttemptsLeft { get; set; }
    public int      StarsEarned  { get; set; }
    public string?  Answer       { get; set; }
    public string?  ShareText    { get; set; }
    public bool     LevelUp      { get; set; }  // Doğru çözüldü, seviye atlandı
    public bool     Milestone    { get; set; }  // Her 10 seviyede kart drop
}

public class WordleLevelStatsDto
{
    public int    CurrentLevel    { get; set; }
    public int    HighestLevel    { get; set; }
    public int    TotalSolved     { get; set; }
    public int    CurrentStreak   { get; set; }
    public int    BestStreak      { get; set; }
    public int    SkipTickets     { get; set; }
    public double AverageAttempts { get; set; }
}
