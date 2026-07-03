using MiniBilge.Application.DTOs.Challenge;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class ChallengeService : IChallengeService
{
    private readonly IChallengeRepository    _challengeRepo;
    private readonly IFriendshipRepository   _friendshipRepo;
    private readonly IChildProfileRepository _childProfileRepo;
    private readonly INotificationService    _notificationService;

    public ChallengeService(
        IChallengeRepository    challengeRepo,
        IFriendshipRepository   friendshipRepo,
        IChildProfileRepository childProfileRepo,
        INotificationService    notificationService)
    {
        _challengeRepo       = challengeRepo;
        _friendshipRepo      = friendshipRepo;
        _childProfileRepo    = childProfileRepo;
        _notificationService = notificationService;
    }

    // ── Send ─────────────────────────────────────────────────────────────────

    public async Task<ChallengeDto> SendChallengeAsync(Guid challengerId, Guid challengeeId, Guid levelId)
    {
        // Arkadaşlık kontrolü
        var friendship = await _friendshipRepo.GetBetweenAsync(challengerId, challengeeId);
        if (friendship == null || friendship.Status != FriendshipStatus.Accepted)
            throw new InvalidOperationException("Yalnızca arkadaşlarınıza meydan okuyabilirsiniz.");

        // Aktif meydan okuma kontrolü
        if (await _challengeRepo.HasActiveChallengeAsync(challengerId, challengeeId))
            throw new InvalidOperationException("Bu kişiyle hâlâ aktif bir meydan okuman var.");

        var expiresAt = DateTime.UtcNow.AddHours(48);
        var created   = await _challengeRepo.CreateAsync(challengerId, challengeeId, levelId, expiresAt);

        // Navigation'larla yeniden yükle
        var challenge = await _challengeRepo.GetByIdAsync(created.Id) ?? created;

        // Push bildirimi
        var challenger = await _childProfileRepo.GetByIdAsync(challengerId);
        await _notificationService.SendChallengeReceivedNotificationAsync(
            challengeeId, challenger?.Name ?? "Biri", challenge.Id);

        return MapToDto(challenge, viewerId: challengerId);
    }

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

        // Her iki taraf da oynadıysa tamamla
        if (challenge.ChallengerScore.HasValue && challenge.ChallengeeScore.HasValue)
        {
            challenge.Status = ChallengeStatus.Completed;
            await _challengeRepo.UpdateAsync(challenge);
            await SendResultNotificationsAsync(challenge);
        }
        else
        {
            await _challengeRepo.UpdateAsync(challenge);
        }

        return MapToDto(challenge, viewerId: childId);
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
