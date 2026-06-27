namespace MiniBilge.Application.DTOs.Writing;

// ─── Prompt Üretimi ──────────────────────────────────────────────────────────

public class GeneratePromptsRequest
{
    /// <summary>CEFR seviyesi: "A1", "A2", "B1", "B2"</summary>
    public string Level { get; set; } = string.Empty;

    /// <summary>Opsiyonel — belirtilirse o bölümün konusuna göre prompt üretilir</summary>
    public Guid? EpisodeId { get; set; }
}

public class WritingPromptDto
{
    public Guid Id { get; set; }
    public string PromptText { get; set; } = string.Empty;

    /// <summary>Prompt hangi bağlamdan türetildiyse kısa açıklaması (ör. "Alice in Wonderland")</summary>
    public string? Context { get; set; }
}

// ─── Değerlendirme ───────────────────────────────────────────────────────────

public class EvaluateWritingRequest
{
    /// <summary>Kullanıcının yazdığı / söylediği metin</summary>
    public string Text { get; set; } = string.Empty;

    /// <summary>Cevaplanan prompt metni (GPT bağlamı için)</summary>
    public string PromptText { get; set; } = string.Empty;

    /// <summary>CEFR seviyesi: "A1", "A2", "B1", "B2"</summary>
    public string Level { get; set; } = string.Empty;

    /// <summary>Giriş yöntemi: "keyboard" | "voice"</summary>
    public string InputMethod { get; set; } = "keyboard";

    /// <summary>Opsiyonel — coin/yıldız eklemek için gerekli</summary>
    public Guid? ChildProfileId { get; set; }
}

public class WritingCorrectionDto
{
    public string Original { get; set; } = string.Empty;
    public string Suggestion { get; set; } = string.Empty;

    /// <summary>English short explanation for the child</summary>
    public string Explanation { get; set; } = string.Empty;

    /// <summary>Turkish translation of Explanation</summary>
    public string ExplanationTr { get; set; } = string.Empty;
}

public class WritingEvaluationResultDto
{
    /// <summary>0–100 arası puan</summary>
    public int Score { get; set; }

    /// <summary>Maksimum 3 düzeltme önerisi</summary>
    public List<WritingCorrectionDto> Corrections { get; set; } = new();

    /// <summary>English encouraging general feedback (max 2 sentences)</summary>
    public string Feedback { get; set; } = string.Empty;

    /// <summary>Turkish translation of Feedback</summary>
    public string FeedbackTr { get; set; } = string.Empty;

    public int CoinsEarned { get; set; }
    public int StarsEarned { get; set; }
}
