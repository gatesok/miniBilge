using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class MatchSession : BaseEntity
{
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public MatchSessionStatus Status { get; set; } = MatchSessionStatus.Created;
    public Guid? WinnerId { get; set; }
    
    // Navigation
    public ICollection<MatchParticipant> Participants { get; set; } = new List<MatchParticipant>();
    public ICollection<MatchQuestion> Questions { get; set; } = new List<MatchQuestion>();
    public ICollection<MatchAnswer> Answers { get; set; } = new List<MatchAnswer>();
}
