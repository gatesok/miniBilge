using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.DTOs.Challenge;

public class ChallengeDto
{
    public Guid   Id                  { get; set; }
    public Guid   ChallengerId        { get; set; }
    public string ChallengerName      { get; set; } = string.Empty;
    public string? ChallengerAvatarUrl { get; set; }
    public Guid   ChallengeeId        { get; set; }
    public string ChallengeeName      { get; set; } = string.Empty;
    public string? ChallengeeAvatarUrl { get; set; }
    public Guid?  LevelId             { get; set; }
    public AdultCompetitionType? CompetitionType { get; set; }
    public string? CompetitionTopicKey { get; set; }
    public string? CompetitionDifficulty { get; set; }
    public string? QuestionPayload { get; set; }
    public string LevelName           { get; set; } = string.Empty;
    public string SubjectName         { get; set; } = string.Empty;
    public ChallengeStatus Status     { get; set; }
    public int?   ChallengerScore     { get; set; }
    public int?   ChallengeeScore     { get; set; }
    public int    TotalQuestions      { get; set; }
    public DateTime  ExpiresAt          { get; set; }
    public DateTime  CreatedAt          { get; set; }
    /// <summary>"Kazandın 🏆" / "Kaybettin 😔" / "Berabere 🤝" — null ise henüz tamamlanmamış.</summary>
    public string?   ResultMessage      { get; set; }
    /// <summary>Son hatırlatma bildiriminin gönderildiği zaman. 4 saat cooldown için kullanılır.</summary>
    public DateTime? LastReminderSentAt { get; set; }
    public int RewardStars { get; set; }
    public int RewardBadgeCount { get; set; }
    public bool RewardCardDropped { get; set; }
    public Guid? RewardCardId { get; set; }
    public string? RewardCardName { get; set; }
    public string? RewardCardRarity { get; set; }
    public string? RewardCardImageAsset { get; set; }
    public bool RewardCardIsNew { get; set; }
}

public class SendChallengeDto
{
    public Guid ChallengerId  { get; set; }
    public Guid ChallengeeId  { get; set; }
    public Guid? LevelId       { get; set; }
    public AdultCompetitionType? CompetitionType { get; set; }
    public string? CompetitionTopicKey { get; set; }
    public string CompetitionDifficulty { get; set; } = "Orta";
}

public class RespondChallengeDto
{
    public Guid ChallengeeId { get; set; }
}

public class SubmitChallengeScoreDto
{
    public Guid ChildId { get; set; }
    public int  Score   { get; set; }
}

public class RemindChallengeDto
{
    public Guid ChallengerId { get; set; }
}
