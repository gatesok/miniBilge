using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class Question : BaseEntity
{
    public Guid LevelId { get; set; }
    public string QuestionText { get; set; } = string.Empty;
    public QuestionType QuestionType { get; set; } = QuestionType.MultipleChoice;
    public string CorrectAnswer { get; set; } = string.Empty;
    public string? Explanation { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public bool HasLatex { get; set; } = false;

    // Navigation properties
    public Level Level { get; set; } = null!;
    public ICollection<QuestionOption> Options { get; set; } = new List<QuestionOption>();
}
