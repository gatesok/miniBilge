using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class QuestionOption : BaseEntity
{
    public Guid QuestionId { get; set; }
    public string OptionText { get; set; } = string.Empty;
    public int DisplayOrder { get; set; } // 0=A, 1=B, 2=C, 3=D
    public bool HasLatex { get; set; } = false;

    // Navigation property
    public Question Question { get; set; } = null!;
}
