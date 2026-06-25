namespace MiniBilge.Application.DTOs.Writing;

// ─── Görev Üretimi ───────────────────────────────────────────────────────────

public class GenerateVocabChallengeRequest
{
    /// <summary>Kelime seçimi için çocuk profil ID</summary>
    public Guid ChildId { get; set; }

    /// <summary>CEFR seviyesi: "A1", "A2", "B1", "B2"</summary>
    public string Level { get; set; } = string.Empty;
}

public class VocabChallengeTaskDto
{
    /// <summary>GPT'nin ürettiği görev metni</summary>
    public string Task { get; set; } = string.Empty;

    /// <summary>Kullanılması gereken hedef kelimeler (2–3 kelime)</summary>
    public List<string> TargetWords { get; set; } = new();
}

// ─── Değerlendirme ───────────────────────────────────────────────────────────

public class EvaluateVocabChallengeRequest
{
    /// <summary>Kullanıcının yazdığı / söylediği metin</summary>
    public string Text { get; set; } = string.Empty;

    /// <summary>Görev metni (GPT bağlamı için)</summary>
    public string TaskText { get; set; } = string.Empty;

    /// <summary>Kullanılması gereken hedef kelimeler</summary>
    public List<string> TargetWords { get; set; } = new();

    /// <summary>CEFR seviyesi</summary>
    public string Level { get; set; } = string.Empty;

    /// <summary>Giriş yöntemi: "keyboard" | "voice"</summary>
    public string InputMethod { get; set; } = "keyboard";

    /// <summary>Opsiyonel — coin/yıldız eklemek için</summary>
    public Guid? ChildProfileId { get; set; }
}

public class VocabChallengeResultDto
{
    /// <summary>0–100 arası puan</summary>
    public int Score { get; set; }

    /// <summary>Her hedef kelimenin kullanılıp kullanılmadığı</summary>
    public Dictionary<string, bool> TargetWordUsage { get; set; } = new();

    /// <summary>Gramer düzeltme önerileri (maks 3)</summary>
    public List<WritingCorrectionDto> Corrections { get; set; } = new();

    /// <summary>Türkçe teşvik edici genel geri bildirim</summary>
    public string Feedback { get; set; } = string.Empty;

    public int CoinsEarned { get; set; }
    public int StarsEarned { get; set; }
}
