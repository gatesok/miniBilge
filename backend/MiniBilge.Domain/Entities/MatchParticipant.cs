using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class MatchParticipant : BaseEntity
{
    public Guid MatchSessionId { get; set; }
    public Guid ChildProfileId { get; set; }
    public int Score { get; set; } = 0;
    public DateTime JoinedAt { get; set; }
    public bool IsReady { get; set; } = false;
    
    // Navigation
    public MatchSession MatchSession { get; set; } = null!;
    public ChildProfile ChildProfile { get; set; } = null!;
    public ICollection<MatchAnswer> Answers { get; set; } = new List<MatchAnswer>();
}
