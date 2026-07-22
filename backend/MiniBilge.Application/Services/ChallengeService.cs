using MiniBilge.Application.DTOs.Challenge;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using System.Text.Json;

namespace MiniBilge.Application.Services;

public class ChallengeService : IChallengeService
{
    private readonly IChallengeRepository    _challengeRepo;
    private readonly IFriendshipRepository   _friendshipRepo;
    private readonly IChildProfileRepository _childProfileRepo;
    private readonly INotificationService    _notificationService;
    private readonly IEntertainmentQuizService _entertainmentService;
    private readonly IAdaptiveQuizService _rewardService;

    public ChallengeService(
        IChallengeRepository    challengeRepo,
        IFriendshipRepository   friendshipRepo,
        IChildProfileRepository childProfileRepo,
        INotificationService    notificationService,
        IEntertainmentQuizService entertainmentService,
        IAdaptiveQuizService rewardService)
    {
        _challengeRepo       = challengeRepo;
        _friendshipRepo      = friendshipRepo;
        _childProfileRepo    = childProfileRepo;
        _notificationService = notificationService;
        _entertainmentService = entertainmentService;
        _rewardService = rewardService;
    }

    // ── Send ─────────────────────────────────────────────────────────────────

    public async Task<ChallengeDto> SendChallengeAsync(SendChallengeDto request)
    {
        var challengerId = request.ChallengerId;
        var challengeeId = request.ChallengeeId;
        // Arkadaşlık kontrolü
        var friendship = await _friendshipRepo.GetBetweenAsync(challengerId, challengeeId);
        if (friendship == null || friendship.Status != FriendshipStatus.Accepted)
            throw new InvalidOperationException("Yalnızca arkadaşlarınıza meydan okuyabilirsiniz.");

        // Aktif meydan okuma kontrolü
        if (await _challengeRepo.HasActiveChallengeAsync(challengerId, challengeeId))
            throw new InvalidOperationException("Bu kişiyle hâlâ aktif bir meydan okuman var.");

        var challenger = await _childProfileRepo.GetByIdAsync(challengerId)
            ?? throw new InvalidOperationException("Meydan okuyan profil bulunamadı.");
        var challengee = await _childProfileRepo.GetByIdAsync(challengeeId)
            ?? throw new InvalidOperationException("Rakip profil bulunamadı.");

        string? questionPayload = null;
        if (challenger.GradeLevel == GradeLevel.Adult)
        {
            if (challengee.GradeLevel != GradeLevel.Adult)
                throw new InvalidOperationException("Yetişkin meydan okumaları yalnızca yetişkin profiller arasında gönderilebilir.");
            if (!request.CompetitionType.HasValue)
                throw new InvalidOperationException("Bir yetişkin yarışma türü seçmelisiniz.");

            var topicKey = string.IsNullOrWhiteSpace(request.CompetitionTopicKey)
                ? TopicKeyFor(request.CompetitionType.Value)
                : request.CompetitionTopicKey;
            var topicParts = topicKey.Split(':', 2);
            var baseTopicKey = topicParts[0];
            var focusTopic = topicParts.Length > 1 ? topicParts[1] : null;
            var questions = await _entertainmentService.GenerateAsync(new GenerateEntertainmentRequest
            {
                TopicKey = baseTopicKey,
                Difficulty = request.CompetitionType == AdultCompetitionType.EnglishQuiz ? "Orta" : request.CompetitionDifficulty,
                FocusTopic = request.CompetitionType == AdultCompetitionType.EnglishQuiz
                    ? $"CEFR {request.CompetitionDifficulty} - {focusTopic}"
                    : focusTopic,
                Count = 10,
                DateSeed = $"challenge:{challengerId}:{challengeeId}:{DateTime.UtcNow:yyyyMMddHH}"
            });
            questionPayload = JsonSerializer.Serialize(questions);
            request.CompetitionTopicKey = topicKey;
        }
        else if (!request.LevelId.HasValue)
        {
            throw new InvalidOperationException("Ders, seviye ve konu seçmelisiniz.");
        }

        var created = await _challengeRepo.CreateAsync(new Challenge
        {
            ChallengerId = challengerId,
            ChallengeeId = challengeeId,
            LevelId = request.LevelId,
            CompetitionType = request.CompetitionType,
            CompetitionTopicKey = request.CompetitionTopicKey,
            CompetitionDifficulty = request.CompetitionDifficulty,
            QuestionPayload = questionPayload,
            Status = ChallengeStatus.Pending,
            TotalQuestions = 10,
            ExpiresAt = DateTime.UtcNow.AddHours(48),
            CreatedAt = DateTime.UtcNow,
        });

        // Navigation'larla yeniden yükle
        var challenge = await _challengeRepo.GetByIdAsync(created.Id) ?? created;

        // Push bildirimi
        await _notificationService.SendChallengeReceivedNotificationAsync(
            challengeeId, challenger?.Name ?? "Biri", challenge.Id);

        return MapToDto(challenge, viewerId: challengerId);
    }

    private static string TopicKeyFor(AdultCompetitionType type) => type switch
    {
        AdultCompetitionType.EnglishQuiz => "ingilizce",
        AdultCompetitionType.EntertainmentQuiz => "sinema",
        AdultCompetitionType.TimedWordle => "kelime",
        AdultCompetitionType.TrueFalseRapid => "genel_kultur",
        AdultCompetitionType.CategoryQuiz => "genel_kultur",
        AdultCompetitionType.DailyChallenge => "genel_kultur",
        _ => "genel_kultur",
    };

    // ── Accept / Decline ─────────────────────────────────────────────────────

    public async Task<ChallengeDto> AcceptChallengeAsync(Guid challengeId, Guid challengeeId)
    {
        var challenge = await GetValidatedAsync(challengeId, challengeeId, mustBeChallengee: true);

        if (challenge.Status != ChallengeStatus.Pending)
            throw new InvalidOperationException("Bu meydan okuma artık kabul edilemez.");

        challenge.Status = ChallengeStatus.ChallengeeAccepted;
        await _challengeRepo.UpdateAsync(challenge);

        // Push bildirimi
        var challengee = await _childProfileRepo.GetByIdAsync(challengeeId);
        await _notificationService.SendChallengeAcceptedNotificationAsync(
            challenge.ChallengerId, challengee?.Name ?? "Arkadaşın");

        return MapToDto(challenge, viewerId: challengeeId);
    }

    public async Task<ChallengeDto> DeclineChallengeAsync(Guid challengeId, Guid challengeeId)
    {
        var challenge = await GetValidatedAsync(challengeId, challengeeId, mustBeChallengee: true);

        if (challenge.Status != ChallengeStatus.Pending)
            throw new InvalidOperationException("Bu meydan okuma artık reddedilemez.");

        challenge.Status = ChallengeStatus.Declined;
        await _challengeRepo.UpdateAsync(challenge);

        return MapToDto(challenge, viewerId: challengeeId);
    }

    // ── Submit Score ──────────────────────────────────────────────────────────

    public async Task<ChallengeDto> SubmitScoreAsync(Guid challengeId, Guid childId, int score)
    {
        var challenge = await _challengeRepo.GetByIdAsync(challengeId)
            ?? throw new KeyNotFoundException("Meydan okuma bulunamadı.");

        bool isChallenger = challenge.ChallengerId == childId;
        bool isChallengee = challenge.ChallengeeId == childId;

        if (!isChallenger && !isChallengee)
            throw new UnauthorizedAccessException("Bu meydan okumada yer almıyorsunuz.");

        if (challenge.Status == ChallengeStatus.Expired ||
            challenge.Status == ChallengeStatus.Declined)
            throw new InvalidOperationException("Bu meydan okuma artık geçerli değil.");

        // Skoru kaydet
        if (isChallenger)
        {
            if (challenge.ChallengerScore.HasValue)
                throw new InvalidOperationException("Skoru zaten gönderdiniz.");
            challenge.ChallengerScore  = score;
            challenge.ChallengerDoneAt = DateTime.UtcNow;
            if (challenge.Status == ChallengeStatus.Pending ||
                challenge.Status == ChallengeStatus.ChallengeeAccepted)
                challenge.Status = ChallengeStatus.ChallengerDone;
        }
        else
        {
            if (challenge.ChallengeeScore.HasValue)
                throw new InvalidOperationException("Skoru zaten gönderdiniz.");
            challenge.ChallengeeScore  = score;
            challenge.ChallengeeDoneAt = DateTime.UtcNow;
        }

        AdaptiveQuizRewardDto? reward = null;
        if (challenge.CompetitionType.HasValue)
        {
            reward = await _rewardService.AwardAsync(childId, new AwardAdaptiveQuizRequest
            {
                CorrectCount = Math.Clamp(score, 0, challenge.TotalQuestions),
                TotalCount = challenge.TotalQuestions,
                TopicName = challenge.CompetitionTopicKey ?? string.Empty,
                SkipAdultCompetitionStats = true,
            });
        }

        // Her iki taraf da oynadıysa tamamla
        if (challenge.ChallengerScore.HasValue && challenge.ChallengeeScore.HasValue)
        {
            challenge.Status = ChallengeStatus.Completed;
            if (challenge.CompetitionType.HasValue)
                await ApplyAdultCompetitionResultAsync(challenge);
            await _challengeRepo.UpdateAsync(challenge);
            await SendResultNotificationsAsync(challenge);
        }
        else
        {
            await _challengeRepo.UpdateAsync(challenge);
        }

        var dto = MapToDto(challenge, viewerId: childId);
        if (reward != null)
        {
            dto.RewardStars = reward.StarsEarned;
            dto.RewardBadgeCount = reward.BadgeCount;
            dto.RewardCardDropped = reward.CardDropped;
            dto.RewardCardId = reward.CardId;
            dto.RewardCardName = reward.CardName;
            dto.RewardCardRarity = reward.CardRarity;
            dto.RewardCardImageAsset = reward.CardImageAsset;
            dto.RewardCardIsNew = reward.CardIsNew;
        }
        return dto;
    }

    private async Task ApplyAdultCompetitionResultAsync(Challenge challenge)
    {
        var challenger = await _childProfileRepo.GetByIdAsync(challenge.ChallengerId);
        var challengee = await _childProfileRepo.GetByIdAsync(challenge.ChallengeeId);
        if (challenger == null || challengee == null) return;

        challenger.AdultCompetitionGamesPlayed++;
        challengee.AdultCompetitionGamesPlayed++;
        challenger.AdultCompetitionPoints += Math.Max(0, challenge.ChallengerScore!.Value) * 10;
        challengee.AdultCompetitionPoints += Math.Max(0, challenge.ChallengeeScore!.Value) * 10;
        if (challenge.ChallengerScore > challenge.ChallengeeScore)
            challenger.AdultCompetitionWins++;
        else if (challenge.ChallengeeScore > challenge.ChallengerScore)
            challengee.AdultCompetitionWins++;

        await _childProfileRepo.UpdateAsync(challenger);
        await _childProfileRepo.UpdateAsync(challengee);
    }

    // ── List ─────────────────────────────────────────────────────────────────

    public async Task<List<ChallengeDto>> GetIncomingAsync(Guid challengeeId)
    {
        var list = await _challengeRepo.GetIncomingAsync(challengeeId);
        return list.Select(c => MapToDto(c, viewerId: challengeeId)).ToList();
    }

    public async Task<List<ChallengeDto>> GetOutgoingAsync(Guid challengerId)
    {
        var list = await _challengeRepo.GetOutgoingAsync(challengerId);
        return list.Select(c => MapToDto(c, viewerId: challengerId)).ToList();
    }

    public async Task<List<ChallengeDto>> GetHistoryAsync(Guid childId)
    {
        var list = await _challengeRepo.GetHistoryAsync(childId);
        return list.Select(c => MapToDto(c, viewerId: childId)).ToList();
    }

    // ── Expire (background job) ───────────────────────────────────────────────

    public Task ExpireOldChallengesAsync()
        => _challengeRepo.ExpireOldAsync();

    // ── Remind ───────────────────────────────────────────────────────────────

    public async Task<ChallengeDto> RemindChallengeAsync(Guid challengeId, Guid challengerId)
    {
        var challenge = await _challengeRepo.GetByIdAsync(challengeId)
            ?? throw new KeyNotFoundException("Meydan okuma bulunamadı.");

        if (challenge.ChallengerId != challengerId)
            throw new UnauthorizedAccessException("Bu meydan okumada bu işlemi yapamazsınız.");

        bool isRemindable =
            challenge.Status == ChallengeStatus.Pending            ||
            challenge.Status == ChallengeStatus.ChallengeeAccepted ||
            challenge.Status == ChallengeStatus.ChallengerDone;

        if (!isRemindable)
            throw new InvalidOperationException("Bu meydan okuma için hatırlatma gönderilemez.");

        if (challenge.LastReminderSentAt.HasValue &&
            DateTime.UtcNow - challenge.LastReminderSentAt.Value < TimeSpan.FromHours(24))
            throw new InvalidOperationException("Hatırlatma zaten gönderildi. Günde 1 kez hatırlatma gönderebilirsin.");

        await _challengeRepo.UpdateReminderSentAtAsync(challengeId, DateTime.UtcNow);

        var challenger = await _childProfileRepo.GetByIdAsync(challengerId);
        await _notificationService.SendChallengeReminderNotificationAsync(
            challenge.ChallengeeId, challenger?.Name ?? "Rakibin", challengeId);

        var updated = await _challengeRepo.GetByIdAsync(challengeId) ?? challenge;
        return MapToDto(updated, viewerId: challengerId);
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private async Task<Challenge> GetValidatedAsync(Guid challengeId, Guid callerId, bool mustBeChallengee)
    {
        var challenge = await _challengeRepo.GetByIdAsync(challengeId)
            ?? throw new KeyNotFoundException("Meydan okuma bulunamadı.");

        if (mustBeChallengee && challenge.ChallengeeId != callerId)
            throw new UnauthorizedAccessException("Bu meydan okumaya müdahale etme yetkiniz yok.");

        return challenge;
    }

    private async Task SendResultNotificationsAsync(Challenge c)
    {
        int chalScore  = c.ChallengerScore!.Value;
        int cheeScore  = c.ChallengeeScore!.Value;
        int total      = c.TotalQuestions;
        string chalName = c.Challenger?.Name ?? "Rakip";
        string cheeName = c.Challengee?.Name ?? "Rakip";

        await _notificationService.SendChallengeResultNotificationAsync(
            c.ChallengerId, cheeName,  myScore: chalScore, opponentScore: cheeScore, total: total, challengeId: c.Id);
        await _notificationService.SendChallengeResultNotificationAsync(
            c.ChallengeeId, chalName, myScore: cheeScore, opponentScore: chalScore, total: total, challengeId: c.Id);
    }

    private static ChallengeDto MapToDto(Challenge c, Guid viewerId)
    {
        string? resultMessage = null;

        if (c.Status == ChallengeStatus.Completed &&
            c.ChallengerScore.HasValue && c.ChallengeeScore.HasValue)
        {
            bool viewerIsChallenger = c.ChallengerId == viewerId;
            int myScore  = viewerIsChallenger ? c.ChallengerScore.Value : c.ChallengeeScore.Value;
            int oppScore = viewerIsChallenger ? c.ChallengeeScore.Value : c.ChallengerScore.Value;

            resultMessage = myScore > oppScore ? "Kazandın 🏆"
                          : myScore < oppScore ? "Kaybettin 😔"
                          : "Berabere 🤝";
        }

        return new ChallengeDto
        {
            Id                  = c.Id,
            ChallengerId        = c.ChallengerId,
            ChallengerName      = c.Challenger?.Name ?? string.Empty,
            ChallengerAvatarUrl = c.Challenger?.AvatarImageUrl,
            ChallengeeId        = c.ChallengeeId,
            ChallengeeName      = c.Challengee?.Name ?? string.Empty,
            ChallengeeAvatarUrl = c.Challengee?.AvatarImageUrl,
            LevelId             = c.LevelId,
            LevelName           = c.Level?.Name ?? string.Empty,
            SubjectName         = c.Level?.Topic?.Subject?.Name ?? string.Empty,
            CompetitionType     = c.CompetitionType,
            CompetitionTopicKey = c.CompetitionTopicKey,
            CompetitionDifficulty = c.CompetitionDifficulty,
            QuestionPayload     = c.QuestionPayload,
            Status              = c.Status,
            ChallengerScore     = c.ChallengerScore,
            ChallengeeScore     = c.ChallengeeScore,
            TotalQuestions      = c.TotalQuestions,
            ExpiresAt           = c.ExpiresAt,
            CreatedAt           = c.CreatedAt,
            ResultMessage       = resultMessage,
            LastReminderSentAt  = c.LastReminderSentAt,
        };
    }
}
