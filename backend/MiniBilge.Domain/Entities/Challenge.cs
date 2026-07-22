using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class Challenge : BaseEntity
{
    public Guid   ChallengerId     { get; set; }
    public Guid   ChallengeeId     { get; set; }
    public Guid?  LevelId          { get; set; }
    public AdultCompetitionType? CompetitionType { get; set; }
    public string? CompetitionTopicKey { get; set; }
    public string? CompetitionDifficulty { get; set; }
    public string? QuestionPayload { get; set; }
    public ChallengeStatus Status  { get; set; } = ChallengeStatus.Pending;
    public int?   ChallengerScore  { get; set; }
    public int?   ChallengeeScore  { get; set; }
    public int    TotalQuestions   { get; set; } = 10;
    public DateTime  ExpiresAt          { get; set; }
    public DateTime? ChallengerDoneAt    { get; set; }
    public DateTime? ChallengeeDoneAt    { get; set; }
    public DateTime? LastReminderSentAt  { get; set; }

    // Navigation
    public virtual ChildProfile Challenger { get; set; } = null!;
    public virtual ChildProfile Challengee { get; set; } = null!;
    public virtual Level?       Level      { get; set; }
}
