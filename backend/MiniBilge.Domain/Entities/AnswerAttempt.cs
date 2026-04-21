using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class AnswerAttempt : BaseEntity
{
    public Guid ChildId { get; set; }
    public Guid QuestionId { get; set; }
    public string SubmittedAnswer { get; set; } = string.Empty;
    public bool IsCorrect { get; set; }
    public int? TimeTakenSeconds { get; set; }
    public DateTime AttemptedAt { get; set; }
    
    // Navigation
    public ChildProfile Child { get; set; } = null!;
    public Question Question { get; set; } = null!;
}
