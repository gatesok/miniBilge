using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class MatchQuestion : BaseEntity
{
    public Guid MatchSessionId { get; set; }
    public Guid QuestionId { get; set; }
    public int QuestionOrder { get; set; } // 1, 2, 3, 4, 5
    
    // Navigation
    public MatchSession MatchSession { get; set; } = null!;
    public Question Question { get; set; } = null!;
}
