namespace MiniBilge.Application.DTOs.Pronunciation;

public class EvaluatePronunciationRequest
{
    /// <summary>Ekranda gösterilen hedef cümle</summary>
    public string TargetSentence { get; set; } = string.Empty;

    /// <summary>speech_to_text'ten gelen okunan metin</summary>
    public string SpokenText { get; set; } = string.Empty;

    /// <summary>CEFR seviyesi: "A1", "A2", "B1", "B2"</summary>
    public string Level { get; set; } = "A1";

    /// <summary>Opsiyonel — pronunciation_attempts logu için</summary>
    public Guid? ChildProfileId { get; set; }
}

public class WordResultDto
{
    /// <summary>Hedef cümledeki kelime (orijinal yazım)</summary>
    public string Word { get; set; } = string.Empty;

    /// <summary>Doğru telaffuz edildi mi?</summary>
    public bool IsCorrect { get; set; }

    /// <summary>Yanlışsa GPT'den gelen kısa telaffuz ipucu (Türkçe)</summary>
    public string? Hint { get; set; }
}

public class PronunciationResultDto
{
    /// <summary>Her kelime için telaffuz sonucu</summary>
    public List<WordResultDto> Words { get; set; } = new();

    /// <summary>0–100 genel skor (doğru/toplam * 100)</summary>
    public int OverallScore { get; set; }
}
