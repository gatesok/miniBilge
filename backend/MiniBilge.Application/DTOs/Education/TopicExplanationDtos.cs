namespace MiniBilge.Application.DTOs.Education;

public class ExplainTopicRequest
{
    /// <summary>CEFR seviyesi: A1, A2, B1, B2</summary>
    public string Level { get; set; } = string.Empty;

    /// <summary>Konu adı (örn. "Present Perfect", "Comparative Adjectives")</summary>
    public string SubjectName { get; set; } = string.Empty;

    /// <summary>Kullanıcının yanlış yaptığı soruların kısa özeti (opsiyonel)</summary>
    public List<string> WrongTopics { get; set; } = [];
}

public class TopicExplanationDto
{
    /// <summary>Ana gramer/kelime kuralı (Türkçe-İngilizce karışık, çocuğa uygun)</summary>
    public string Rule { get; set; } = string.Empty;

    /// <summary>3 örnek cümle</summary>
    public List<string> Examples { get; set; } = [];

    /// <summary>Sık yapılan hatalar</summary>
    public List<string> CommonMistakes { get; set; } = [];

    /// <summary>Hatırlatıcı pratik ipucu</summary>
    public string Tip { get; set; } = string.Empty;
}
