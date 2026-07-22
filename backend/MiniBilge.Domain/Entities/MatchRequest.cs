using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class MatchRequest : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public Guid? SubjectId { get; set; }
    public Guid? LevelId { get; set; }
    public AdultCompetitionType? CompetitionType { get; set; }
    public string? CompetitionTopicKey { get; set; }
    public string? CompetitionDifficulty { get; set; }
    public DateTime RequestedAt { get; set; }
    public MatchRequestStatus Status { get; set; } = MatchRequestStatus.Waiting;
    public DateTime? MatchedAt { get; set; }
    public Guid? MatchSessionId { get; set; }
    
    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public MatchSession? MatchSession { get; set; }
}
