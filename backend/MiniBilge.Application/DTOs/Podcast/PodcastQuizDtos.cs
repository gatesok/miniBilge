using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.DTOs.Podcast;

/// <summary>
/// Soru listesi endpoint'i için — CorrectAnswer gönderilmez (güvenlik)
/// </summary>
public class PodcastQuestionDto
{
    public Guid Id { get; set; }
    public string QuestionText { get; set; } = string.Empty;
    public PodcastQuestionType QuestionType { get; set; }
    public int DisplayOrder { get; set; }
    public List<PodcastQuestionOptionDto> Options { get; set; } = new();
}

public class PodcastQuestionOptionDto
{
    public Guid Id { get; set; }
    public string OptionText { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
}

/// <summary>
/// Quiz cevap gönderme request'i
/// </summary>
public class PodcastQuizSubmitRequest
{
    public Guid ChildProfileId { get; set; }
    public List<PodcastQuizAnswerDto> Answers { get; set; } = new();
}

public class PodcastQuizAnswerDto
{
    public Guid QuestionId { get; set; }
    public string SelectedAnswer { get; set; } = string.Empty;
}

/// <summary>
/// Quiz tamamlanma sonucu — doğru/yanlış bilgisi + açıklama
/// </summary>
public class PodcastQuizResultDto
{
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public int StarsEarned { get; set; }
    public int CoinsEarned { get; set; }
    public bool IsFirstCompletion { get; set; }
    public List<PodcastQuizAnswerResultDto> AnswerResults { get; set; } = new();
}

public class PodcastQuizAnswerResultDto
{
    public Guid QuestionId { get; set; }
    public bool IsCorrect { get; set; }
    public string CorrectAnswer { get; set; } = string.Empty;
    public string? Explanation { get; set; }
}
