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
    /// <summary>Görüntüleyen profilin son hatırlatma zamanı. 2 saatlik cooldown için kullanılır.</summary>
    public DateTime? LastReminderSentAt { get; set; }
    public int RewardStars { get; set; }
    public int RewardBadgeCount { get; set; }
    /// <summary>Kazanılan rozet anahtarları (istemci zengin overlay gösterir).</summary>
    public List<string> RewardBadges { get; set; } = new();
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

/// <summary>
/// Bir yetişkin profilinin bugün sıralama (turnuva) puanı üretebilme durumu.
/// Kullanıcıya "bu karşılaşma sıralama puanı getirecek mi?" bilgisini gösterir.
/// </summary>
public class AdultRankedStatusDto
{
    /// <summary>Bugün sıralama puanı üretebilecek kalan tamamlama sayısı.</summary>
    public int RankedRemainingToday { get; set; }

    /// <summary>Günlük sıralama üst sınırı (ör. 3).</summary>
    public int DailyRankedLimit { get; set; }

    /// <summary>Sıradaki tamamlanan oyun sıralama puanı üretecek mi?</summary>
    public bool NextGameRanked { get; set; }

    /// <summary>opponentId verildiyse: bu rakibe karşı sıralama puanı hâlâ üretilebilir mi? (aksi halde null)</summary>
    public bool? VsOpponentEligible { get; set; }
}

public class SubmitChallengeScoreDto
{
    public Guid ChildId { get; set; }
    public int  Score   { get; set; }
}

public class RemindChallengeDto
{
    /// <summary>Hatırlatmayı gönderen profil.</summary>
    public Guid RequesterId { get; set; }

    /// <summary>Eski mobil istemcilerle geriye uyumluluk için korunur.</summary>
    public Guid ChallengerId { get; set; }
}
