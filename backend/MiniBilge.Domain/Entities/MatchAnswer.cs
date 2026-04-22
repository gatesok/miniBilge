using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class MatchAnswer : BaseEntity
{
    public Guid MatchSessionId { get; set; }
    public Guid ParticipantId { get; set; }
    public Guid QuestionId { get; set; }
    public string Answer { get; set; } = string.Empty;
    public bool IsCorrect { get; set; }
    public DateTime AnsweredAt { get; set; }
    public int PointsEarned { get; set; }
    
    // Navigation
    public MatchSession MatchSession { get; set; } = null!;
    public MatchParticipant Participant { get; set; } = null!;
    public Question Question { get; set; } = null!;
}
