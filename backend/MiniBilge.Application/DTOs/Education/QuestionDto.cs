using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.DTOs.Education;

public class QuestionDto
{
    public Guid Id { get; set; }
    public Guid LevelId { get; set; }
    public string QuestionText { get; set; } = string.Empty;
    public QuestionType QuestionType { get; set; }
    public string? Explanation { get; set; }
    public bool HasLatex { get; set; } = false;
    public List<QuestionOptionDto> Options { get; set; } = new();
    
    // CorrectAnswer client'a gönderilmez (güvenlik)
}
