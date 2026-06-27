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
    /// <summary>Grammar/vocabulary rule in English</summary>
    public string Rule { get; set; } = string.Empty;

    /// <summary>Turkish translation of Rule</summary>
    public string RuleTr { get; set; } = string.Empty;

    /// <summary>3 English example sentences</summary>
    public List<string> Examples { get; set; } = [];

    /// <summary>Common mistakes in English</summary>
    public List<string> CommonMistakes { get; set; } = [];

    /// <summary>Turkish translations of CommonMistakes</summary>
    public List<string> CommonMistakesTr { get; set; } = [];

    /// <summary>Short encouraging practice tip in English</summary>
    public string Tip { get; set; } = string.Empty;

    /// <summary>Turkish translation of Tip</summary>
    public string TipTr { get; set; } = string.Empty;
}
