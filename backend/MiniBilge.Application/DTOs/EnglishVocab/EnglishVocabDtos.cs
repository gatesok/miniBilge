namespace MiniBilge.Application.DTOs.EnglishVocab;

/// <summary>Kelime quizi soru üretimi isteği.</summary>
public class GenerateVocabQuizRequest
{
    /// <summary>Kullanıcının seçtiği CEFR seviyesi (A1..C2).</summary>
    public string EnglishLevel { get; set; } = string.Empty;

    public int Count { get; set; } = 10;

    /// <summary>Daha önce gösterilen kelime ID'leri — tekrar önleme (oturum + kalıcı).</summary>
    public List<int> ExcludeIds { get; set; } = [];
}

/// <summary>Dinamik çeldiricilerle üretilmiş tek bir soru.</summary>
public class VocabQuestionDto
{
    public int    Id            { get; set; }
    public string EnglishWord   { get; set; } = string.Empty;
    public string OptionA       { get; set; } = string.Empty;
    public string OptionB       { get; set; } = string.Empty;
    public string OptionC       { get; set; } = string.Empty;
    public string OptionD       { get; set; } = string.Empty;
    public string CorrectAnswer { get; set; } = string.Empty; // "A"|"B"|"C"|"D"
    public string? ExampleSentence { get; set; }
}

/// <summary>Kelime quizi tamamlama ödülü isteği.</summary>
public class AwardVocabQuizRequest
{
    public int CorrectCount { get; set; }
    public int TotalCount   { get; set; }
    /// <summary>Oynanan CEFR seviyesi (A1..C2) — aktivite kaydı için.</summary>
    public string EnglishLevel { get; set; } = string.Empty;
    /// <summary>İstemcinin ölçtüğü oyun süresi (saniye). Haftalık çalışma süresine eklenir.</summary>
    public int? DurationSeconds { get; set; }
    /// <summary>İstemcinin her tamamlanan quiz için ürettiği benzersiz anahtar (idempotency).</summary>
    public string? RewardEventId { get; set; }
}
