using MiniBilge.Application.DTOs.Challenge;
using MiniBilge.Application.Interfaces;
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
    private readonly IGameStatsRepository _gameStatsRepo;
    private readonly IBadgeService _badgeService;
    private readonly IAdultTournamentService _tournamentService;
    private readonly IDailyUsageService _dailyUsageService;

    /// <summary>Yetişkin meydan okuma başlatma günlük kotası özellik anahtarı.</summary>
    private const string AdultChallengeFeatureKey = "adult_challenge";

    /// <summary>Bir profilin günde sıralama puanı üretebileceği en fazla tamamlanan oyun (§5).</summary>
    private const int DailyRankedLimit = 3;

    /// <summary>Aynı rakibe karşı günde sıralama puanı üretebilen en fazla oyun (§5.4).</summary>
    private const int RepeatOpponentRankedLimit = 1;

    public ChallengeService(
        IChallengeRepository    challengeRepo,
        IFriendshipRepository   friendshipRepo,
        IChildProfileRepository childProfileRepo,
        INotificationService    notificationService,
        IEntertainmentQuizService entertainmentService,
        IAdaptiveQuizService rewardService,
        IGameStatsRepository gameStatsRepo,
        IBadgeService badgeService,
        IAdultTournamentService tournamentService,
        IDailyUsageService dailyUsageService)
    {
        _challengeRepo       = challengeRepo;
        _friendshipRepo      = friendshipRepo;
        _childProfileRepo    = childProfileRepo;
        _notificationService = notificationService;
        _entertainmentService = entertainmentService;
        _rewardService = rewardService;
        _gameStatsRepo = gameStatsRepo;
        _badgeService = badgeService;
        _tournamentService = tournamentService;
        _dailyUsageService = dailyUsageService;
    }

    // ── Send ─────────────────────────────────────────────────────────────────

    public async Task<ChallengeDto> SendChallengeAsync(SendChallengeDto request, Guid? actingUserId = null)
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

        bool consumedAdultQuota = false;
        try
        {
        string? questionPayload = null;
        if (challenger.GradeLevel == GradeLevel.Adult)
        {
            if (challengee.GradeLevel != GradeLevel.Adult)
                throw new InvalidOperationException("Yetişkin meydan okumaları yalnızca yetişkin profiller arasında gönderilebilir.");
            if (!request.CompetitionType.HasValue)
                throw new InvalidOperationException("Bir yetişkin yarışma türü seçmelisiniz.");

            // Kota: yetişkin meydan okuması BAŞLATIRKEN günlük hakkı tüket. Gelen
            // meydan okumayı kabul/tamamlamak kota TÜKETMEZ. Limit dolarsa
            // DailyUsageLimitExceededException fırlar → controller 429 döner.
            // Bu noktada consumedAdultQuota hâlâ false olduğundan limit hatası
            // aşağıdaki catch tarafından yakalanmaz, yukarı propagate olur.
            if (actingUserId.HasValue)
            {
                await _dailyUsageService.ConsumeAsync(
                    actingUserId.Value, challengerId, AdultChallengeFeatureKey);
                consumedAdultQuota = true;
            }

            var topicKey = string.IsNullOrWhiteSpace(request.CompetitionTopicKey)
                ? TopicKeyFor(request.CompetitionType.Value)
                : request.CompetitionTopicKey;
            var topicParts = topicKey.Split(':', 2);
            var baseTopicKey = topicParts[0];
            var focusTopic = topicParts.Length > 1 ? topicParts[1] : null;

            var turkeyTimeZone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
            var turkeyToday = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, turkeyTimeZone).Date;
            var dayStartUtc = TimeZoneInfo.ConvertTimeToUtc(
                DateTime.SpecifyKind(turkeyToday, DateTimeKind.Unspecified), turkeyTimeZone);
            var todaysChallenges = await _challengeRepo.GetBetweenSinceAsync(
                challengerId, challengeeId, dayStartUtc);
            // Ayrıca meydan okuyanın son günlerdeki (tüm rakiplere karşı) sorularını
            // da hariç tut → aynı soruların birkaç yarışta bir tekrarını azaltır.
            var recentChallenges = await _challengeRepo.GetRecentWithPayloadByProfileAsync(
                challengerId, DateTime.UtcNow.AddDays(-3));
            var excludedIds = new HashSet<int>();
            var forbiddenQuestions = new HashSet<string>(StringComparer.OrdinalIgnoreCase);
            foreach (var previous in todaysChallenges.Concat(recentChallenges))
            {
                try
                {
                    var previousQuestions = JsonSerializer.Deserialize<List<EntertainmentQuestionDto>>(
                        previous.QuestionPayload!);
                    if (previousQuestions == null) continue;
                    foreach (var question in previousQuestions)
                    {
                        if (question.Id > 0) excludedIds.Add(question.Id);
                        forbiddenQuestions.Add(NormalizeQuestion(question.QuestionText));
                    }
                }
                catch (JsonException)
                {
                    // Eski/bozuk payload tekrar önlemeyi durdurmamalı.
                }
            }

            var questions = new List<EntertainmentQuestionDto>();
            for (var attempt = 0; attempt < 3 && questions.Count < 10; attempt++)
            {
                var generated = await _entertainmentService.GenerateAsync(new GenerateEntertainmentRequest
                {
                    TopicKey = baseTopicKey,
                    Difficulty = request.CompetitionType == AdultCompetitionType.EnglishQuiz ? "Orta" : request.CompetitionDifficulty,
                    FocusTopic = request.CompetitionType == AdultCompetitionType.EnglishQuiz
                        ? $"CEFR {request.CompetitionDifficulty} - {focusTopic}"
                        : focusTopic,
                    Count = 10 - questions.Count,
                    ExcludeIds = excludedIds.ToList(),
                    AskedQuestions = forbiddenQuestions.ToList(),
                    DateSeed = $"challenge:{challengerId}:{challengeeId}:{DateTime.UtcNow:yyyyMMdd}:{attempt}"
                });

                foreach (var question in generated)
                {
                    var normalized = NormalizeQuestion(question.QuestionText);
                    if (string.IsNullOrWhiteSpace(normalized) || !forbiddenQuestions.Add(normalized))
                        continue;
                    if (question.Id > 0) excludedIds.Add(question.Id);
                    questions.Add(question);
                    if (questions.Count == 10) break;
                }
            }
            if (questions.Count < 10)
                throw new InvalidOperationException(
                    "Bugün bu kişiyle oynanmamış yeterli sayıda yeni soru bulunamadı. Yarın tekrar deneyebilirsiniz.");

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
        catch when (consumedAdultQuota)
        {
            // Teknik/iş hatası ile oluşturma tamamlanamadı: tüketilen hakkı geri
            // ver (hak kaybedilmez), ardından orijinal hatayı yeniden fırlat.
            try
            {
                await _dailyUsageService.RefundAsync(
                    actingUserId!.Value, challengerId, AdultChallengeFeatureKey);
            }
            catch
            {
                // Telafi başarısızlığı asıl hatayı gizlememeli.
            }
            throw;
        }
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

    private static string NormalizeQuestion(string text) =>
        string.Join(' ', text.Trim().ToLowerInvariant()
            .Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));

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
        IReadOnlyList<string>? callerChallengeBadges = null;
        if (challenge.ChallengerScore.HasValue && challenge.ChallengeeScore.HasValue)
        {
            challenge.Status = ChallengeStatus.Completed;
            if (challenge.CompetitionType.HasValue)
                await ApplyAdultCompetitionResultAsync(challenge);
            await _challengeRepo.UpdateAsync(challenge);

            // Meydan okuma istatistiklerini güncelle ve aile rozetlerini değerlendir.
            // Skor gönderim koruması sayesinde bu blok her meydan okuma için yalnızca bir kez çalışır.
            var challengeBadges = await ApplyChallengeStatsAndBadgesAsync(challenge);
            challengeBadges.TryGetValue(childId, out callerChallengeBadges);

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
            dto.RewardBadges = reward.EarnedBadges;
            dto.RewardCardDropped = reward.CardDropped;
            dto.RewardCardId = reward.CardId;
            dto.RewardCardName = reward.CardName;
            dto.RewardCardRarity = reward.CardRarity;
            dto.RewardCardImageAsset = reward.CardImageAsset;
            dto.RewardCardIsNew = reward.CardIsNew;
        }

        // Çağıranın meydan okuma aile rozetlerini yanıta ekle (async meydan okumada
        // ilk oyuncu kendi rozetlerini koleksiyonundan/bildiriminden görür).
        if (callerChallengeBadges is { Count: > 0 })
        {
            var merged = dto.RewardBadges.Concat(callerChallengeBadges).Distinct().ToList();
            dto.RewardBadges = merged;
            dto.RewardBadgeCount = merged.Count;
        }
        return dto;
    }

    /// <summary>
    /// Tamamlanmış bir meydan okumanın her iki oyuncusu için istatistikleri günceller
    /// ve meydan okuma aile rozetlerini değerlendirir. Oyuncu başına kazanılan rozet
    /// anahtarlarını döndürür.
    /// </summary>
    private async Task<Dictionary<Guid, IReadOnlyList<string>>> ApplyChallengeStatsAndBadgesAsync(Challenge challenge)
    {
        var result = new Dictionary<Guid, IReadOnlyList<string>>();
        int challengerScore = challenge.ChallengerScore!.Value;
        int challengeeScore = challenge.ChallengeeScore!.Value;
        int total = challenge.TotalQuestions;
        // Yetişkin meydan okumalarında kategori topic anahtarıdır; çocuk (seviye) meydan
        // okumalarında topic yoktur, "genel" olarak sayılır.
        string category = string.IsNullOrWhiteSpace(challenge.CompetitionTopicKey)
            ? "genel"
            : challenge.CompetitionTopicKey!;

        var challengerOutcome = challengerScore > challengeeScore ? GameOutcome.Win
            : challengerScore < challengeeScore ? GameOutcome.Loss : GameOutcome.Tie;
        result[challenge.ChallengerId] = await ApplyOneChallengeResultAsync(
            challenge.ChallengerId, category, challengerScore, total, challengerOutcome);

        var challengeeOutcome = challengeeScore > challengerScore ? GameOutcome.Win
            : challengeeScore < challengerScore ? GameOutcome.Loss : GameOutcome.Tie;
        result[challenge.ChallengeeId] = await ApplyOneChallengeResultAsync(
            challenge.ChallengeeId, category, challengeeScore, total, challengeeOutcome);

        return result;
    }

    private async Task<IReadOnlyList<string>> ApplyOneChallengeResultAsync(
        Guid childId, string category, int score, int total, GameOutcome outcome)
    {
        bool perfect = outcome == GameOutcome.Win && total > 0 && score >= total;
        int successPct = total > 0 ? (int)Math.Round(100.0 * score / total) : 0;

        var snap = await _gameStatsRepo.ApplyResultAsync(
            childId, "challenge", category, outcome, perfect, successPct);

        var ctx = new BadgeTriggerContext
        {
            ChallengeWon = outcome == GameOutcome.Win,
            TotalChallengeWins = snap.TotalWon,
            ConsecutiveChallengeWins = snap.CurrentWinStreak,
            ChallengePerfectWin = perfect,
            DistinctChallengeCategoriesWon = snap.DistinctCategoriesWon,
        };
        return await _badgeService.CheckAndAwardAsync(childId, BadgeTrigger.ChallengeCompleted, ctx);
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

        // §5 Rekabet adaleti: Dönemsel sıralama (haftalık turnuva) puanı yalnızca
        // günün ilk N tamamlanan oyununda ve aynı rakibe karşı ilk oyunda üretilir.
        // Bu kural üyelikten BAĞIMSIZDIR; Premium fazla oynasa da ek sıralama
        // avantajı kazanamaz. İstatistik/rozet/puan yukarıda zaten işlendi.
        var dayStartUtc = TurkeyDayStartUtc();
        var challengerRanked = await IsRankedEligibleAsync(
            challenge.ChallengerId, challenge.ChallengeeId, dayStartUtc, challenge.Id);
        var challengeeRanked = await IsRankedEligibleAsync(
            challenge.ChallengeeId, challenge.ChallengerId, dayStartUtc, challenge.Id);

        // P7-M05: Eğlence meydan okuması ise bu haftanın turnuva sıralamasına işle.
        // (Kategori eğlence kategorisi değilse — ör. İngilizce — servis sessizce yok sayar.)
        if (challengerRanked)
            await _tournamentService.RecordResultAsync(
                challenge.ChallengerId,
                challenge.CompetitionTopicKey,
                Math.Max(0, challenge.ChallengerScore!.Value) * 10,
                challenge.ChallengerScore > challenge.ChallengeeScore,
                challenge.CompetitionDifficulty,
                0, 0);
        if (challengeeRanked)
            await _tournamentService.RecordResultAsync(
                challenge.ChallengeeId,
                challenge.CompetitionTopicKey,
                Math.Max(0, challenge.ChallengeeScore!.Value) * 10,
                challenge.ChallengeeScore > challenge.ChallengerScore,
                challenge.CompetitionDifficulty,
                0, 0);
    }

    /// <summary>
    /// Bir profilin mevcut tamamlanan oyununun dönemsel sıralama puanı üretip
    /// üretmeyeceğini belirler: günün ilk <see cref="DailyRankedLimit"/> oyunu ve
    /// aynı rakibe karşı ilk <see cref="RepeatOpponentRankedLimit"/> oyun uygundur.
    /// </summary>
    private async Task<bool> IsRankedEligibleAsync(
        Guid profileId, Guid opponentId, DateTime dayStartUtc, Guid currentChallengeId)
    {
        var completedToday = await _challengeRepo.CountCompletedAdultCompetitionsTodayAsync(
            profileId, dayStartUtc, null, currentChallengeId);
        if (completedToday >= DailyRankedLimit) return false;

        var vsOpponentToday = await _challengeRepo.CountCompletedAdultCompetitionsTodayAsync(
            profileId, dayStartUtc, opponentId, currentChallengeId);
        if (vsOpponentToday >= RepeatOpponentRankedLimit) return false;

        return true;
    }

    private static DateTime TurkeyDayStartUtc()
    {
        var tz = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
        var today = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, tz).Date;
        return TimeZoneInfo.ConvertTimeToUtc(
            DateTime.SpecifyKind(today, DateTimeKind.Unspecified), tz);
    }

    public async Task<AdultRankedStatusDto> GetAdultRankedStatusAsync(
        Guid profileId, Guid? opponentId = null)
    {
        var dayStartUtc = TurkeyDayStartUtc();
        var completedToday = await _challengeRepo.CountCompletedAdultCompetitionsTodayAsync(
            profileId, dayStartUtc, null, Guid.Empty);
        var remaining = Math.Max(0, DailyRankedLimit - completedToday);

        bool? vsOpponentEligible = null;
        if (opponentId.HasValue)
        {
            var vsOpponentToday = await _challengeRepo.CountCompletedAdultCompetitionsTodayAsync(
                profileId, dayStartUtc, opponentId.Value, Guid.Empty);
            vsOpponentEligible = vsOpponentToday < RepeatOpponentRankedLimit;
        }

        return new AdultRankedStatusDto
        {
            RankedRemainingToday = remaining,
            DailyRankedLimit = DailyRankedLimit,
            NextGameRanked = remaining > 0 && (vsOpponentEligible ?? true),
            VsOpponentEligible = vsOpponentEligible,
        };
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

    public async Task<ChallengeDto> RemindChallengeAsync(Guid challengeId, Guid requesterId)
    {
        var challenge = await _challengeRepo.GetByIdAsync(challengeId)
            ?? throw new KeyNotFoundException("Meydan okuma bulunamadı.");

        var requesterIsChallenger = challenge.ChallengerId == requesterId;
        var requesterIsChallengee = challenge.ChallengeeId == requesterId;
        if (!requesterIsChallenger && !requesterIsChallengee)
            throw new UnauthorizedAccessException("Bu meydan okumada bu işlemi yapamazsınız.");

        if (challenge.Status is ChallengeStatus.Completed or ChallengeStatus.Expired or ChallengeStatus.Declined)
            throw new InvalidOperationException("Bu meydan okuma için hatırlatma gönderilemez.");

        // Meydan okuyan, karşı taraf henüz oynamadıysa; meydan okunan ise
        // kendi oyununu tamamlayıp meydan okuyanı bekliyorsa hatırlatabilir.
        var targetId = Guid.Empty;
        var targetName = string.Empty;
        var completedPlayerReminder = false;
        if (requesterIsChallenger && !challenge.ChallengeeScore.HasValue)
        {
            targetId = challenge.ChallengeeId;
            targetName = challenge.Challenger?.Name ?? "Rakibin";
        }
        else if (requesterIsChallengee &&
                 challenge.ChallengeeScore.HasValue &&
                 !challenge.ChallengerScore.HasValue)
        {
            targetId = challenge.ChallengerId;
            targetName = challenge.Challengee?.Name ?? "Rakibin";
            completedPlayerReminder = true;
        }
        else
        {
            throw new InvalidOperationException("Rakibin şu anda hatırlatılacak bir hamlesi yok.");
        }

        var lastReminderAt = requesterIsChallenger
            ? challenge.LastChallengerReminderSentAt ?? challenge.LastReminderSentAt
            : challenge.LastChallengeeReminderSentAt;
        if (lastReminderAt.HasValue &&
            DateTime.UtcNow - lastReminderAt.Value < TimeSpan.FromHours(2))
            throw new InvalidOperationException("Hatırlatma zaten gönderildi. 2 saatte 1 kez hatırlatma gönderebilirsin.");

        await _challengeRepo.UpdateReminderSentAtAsync(
            challengeId,
            sentByChallenger: requesterIsChallenger,
            sentAt: DateTime.UtcNow);

        if (completedPlayerReminder)
        {
            await _notificationService.SendChallengeCompletionReminderNotificationAsync(
                targetId, targetName, challengeId);
        }
        else
        {
            await _notificationService.SendChallengeReminderNotificationAsync(
                targetId, targetName, challengeId);
        }

        var updated = await _challengeRepo.GetByIdAsync(challengeId) ?? challenge;
        return MapToDto(updated, viewerId: requesterId);
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
            LastReminderSentAt  = c.ChallengerId == viewerId
                ? c.LastChallengerReminderSentAt ?? c.LastReminderSentAt
                : c.LastChallengeeReminderSentAt,
        };
    }
}
