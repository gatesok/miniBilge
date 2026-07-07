namespace MiniBilge.Application.DTOs.Wordle;

// ── İstek DTO'ları ────────────────────────────────────────────────────────────

public class SubmitGuessRequest
{
    /// <summary>Büyük harfli 5 karakterli Türkçe tahmin.</summary>
    public string Guess { get; set; } = string.Empty;
}

// ── Yanıt DTO'ları ────────────────────────────────────────────────────────────

public class WordleTodayDto
{
    /// <summary>Bugünün tarihi (oyun ID'si olarak kullanılır).</summary>
    public DateOnly Date         { get; set; }
    public int      WordLength   { get; set; } = 5;
    public int      MaxAttempts  { get; set; } = 6;
    public int      AttemptsUsed { get; set; }
    public bool     Solved       { get; set; }
    public bool     Finished     { get; set; }  // Solved veya hak bitti
    /// <summary>Önceki tahminler — oyunu sürdürmek için.</summary>
    public List<WordleGuessDto> PreviousGuesses { get; set; } = [];
}

public class WordleGuessDto
{
    public string   Guess   { get; set; } = string.Empty;
    /// <summary>"correct" | "present" | "absent" — her harf için.</summary>
    public string[] Pattern { get; set; } = [];
}

public class SubmitGuessResponse
{
    public string[] Pattern      { get; set; } = [];
    public bool     Solved       { get; set; }
    public bool     Finished     { get; set; }
    public int      AttemptsLeft { get; set; }
    /// <summary>Oyun bitti ve doğru cevap açıklanabilir.</summary>
    public string?  Answer       { get; set; }
    /// <summary>Oyun bitti: paylaşım için emoji satırları.</summary>
    public string?  ShareText    { get; set; }
    /// <summary>Kelime çözüldüğünde kazanılan yıldız (0 = çözülmedi).</summary>
    public int      StarsEarned  { get; set; }
}

public class WordleStatsDto
{
    public int    TotalPlayed    { get; set; }
    public int    TotalSolved    { get; set; }
    public int    CurrentStreak  { get; set; }
    public int    BestStreak     { get; set; }
    public double AverageAttempts { get; set; }
    /// <summary>Dağılım: kaç denemede kaç kez çözdü (1..6).</summary>
    public Dictionary<int, int> GuessDist { get; set; } = [];
}
