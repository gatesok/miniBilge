using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using System.Collections.Concurrent;

namespace MiniBilge.API.Hubs;

[Authorize]
public class MatchHub : Hub
{
    private readonly IMatchRepository _matchRepository;
    private readonly IProgressRepository _progressRepository;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IBadgeService _badgeService;
    private readonly ICardDropService _cardDropService;
    private readonly IGameStatsRepository _gameStatsRepository;
    private readonly ILogger<MatchHub> _logger;

    // Tracks which match each connection is in: connectionId → (childId, matchId)
    private static readonly ConcurrentDictionary<string, (string ChildId, string MatchId)> _connectionMatchMap = new();

    // Per-match semaphore: ensures only ONE thread completes a given match (prevents double-complete race condition)
    private static readonly ConcurrentDictionary<string, SemaphoreSlim> _matchCompletionLocks = new();

    // Sıralama puanı anti-abuse limitleri (üyelikten bağımsız): günün ilk 5 tamamlanan
    // canlı yarışı + aynı rakiple en fazla 2 maç sıralama puanı (TotalScore) üretir.
    private const int DailyRankingMatchCap = 5;
    private const int DailyRankingSameOpponentCap = 2;

    public MatchHub(
        IMatchRepository matchRepository,
        IProgressRepository progressRepository,
        IChildProfileRepository childProfileRepository,
        IBadgeService badgeService,
        ICardDropService cardDropService,
        IGameStatsRepository gameStatsRepository,
        ILogger<MatchHub> logger)
    {
        _matchRepository = matchRepository;
        _progressRepository = progressRepository;
        _childProfileRepository = childProfileRepository;
        _badgeService = badgeService;
        _cardDropService = cardDropService;
        _gameStatsRepository = gameStatsRepository;
        _logger = logger;
    }

    public override async Task OnConnectedAsync()
    {
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            _logger.LogInformation("[MATCH HUB] Client connected: {ChildId}", childId);
        }
        
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        _logger.LogInformation("[MATCH HUB] Client disconnected: {ConnectionId}", Context.ConnectionId);

        if (_connectionMatchMap.TryRemove(Context.ConnectionId, out var entry))
        {
            _logger.LogInformation("[MATCH HUB] Auto-forfeit for child {ChildId} in match {MatchId}", entry.ChildId, entry.MatchId);
            await ApplyForfeit(entry.ChildId, entry.MatchId);
        }

        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Client joins a specific match group
    /// </summary>
    public async Task JoinMatch(string matchId, string childId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"match_{matchId}");
        if (!string.IsNullOrEmpty(childId))
        {
            _connectionMatchMap[Context.ConnectionId] = (childId, matchId);
        }
        _logger.LogInformation("[MATCH HUB] Client {ConnectionId} joined match {MatchId} as child {ChildId}", Context.ConnectionId, matchId, childId);
    }

    /// <summary>
    /// Client leaves a specific match group
    /// </summary>
    public async Task LeaveMatchGroup(string matchId)
    {
        _connectionMatchMap.TryRemove(Context.ConnectionId, out _);
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"match_{matchId}");
        _logger.LogInformation("[MATCH HUB] Client {ConnectionId} left match {MatchId}", Context.ConnectionId, matchId);
    }

    /// <summary>
    /// Submit an answer for a question in the match
    /// </summary>
    public async Task SubmitAnswer(string matchId, string questionId, string answer, string childId)
    {
        try
        {
            if (!Guid.TryParse(childId, out var childGuid))
            {
                await Clients.Caller.SendAsync("Error", "Invalid child ID");
                return;
            }

            if (!Guid.TryParse(matchId, out var matchGuid) || !Guid.TryParse(questionId, out var questionGuid))
            {
                await Clients.Caller.SendAsync("Error", "Invalid match or question ID");
                return;
            }

            _logger.LogInformation("[MATCH HUB] Answer submitted - Match: {MatchId}, Child: {ChildId}, Question: {QuestionId}, Answer: {Answer}", matchId, childGuid, questionId, answer);

            // Get match session
            var matchSession = await _matchRepository.GetMatchSessionAsync(matchGuid, includeAll: true);
            if (matchSession == null)
            {
                await Clients.Caller.SendAsync("Error", "Match not found");
                return;
            }

            // Get participant
            var participant = await _matchRepository.GetParticipantAsync(matchGuid, childGuid);
            if (participant == null)
            {
                await Clients.Caller.SendAsync("Error", "Participant not found");
                return;
            }

            // Check if already answered this question
            var existingAnswer = await _matchRepository.GetAnswerAsync(participant.Id, questionGuid);
            if (existingAnswer != null)
            {
                await Clients.Caller.SendAsync("Error", "Question already answered");
                return;
            }

            // Get question to check correct answer
            var matchQuestion = matchSession.Questions.FirstOrDefault(q => q.QuestionId == questionGuid);
            if (matchQuestion == null)
            {
                await Clients.Caller.SendAsync("Error", "Question not found in match");
                return;
            }

            var question = matchQuestion.Question;
            var isCorrect = question.CorrectAnswer?.Trim().Equals(answer.Trim(), StringComparison.OrdinalIgnoreCase) ?? false;
            var pointsEarned = isCorrect ? 10 : 0;

            // Submit answer
            var matchAnswer = await _matchRepository.SubmitAnswerAsync(
                matchGuid, 
                participant.Id, 
                questionGuid, 
                answer, 
                isCorrect, 
                pointsEarned);

            // Update participant score
            var newScore = participant.Score + pointsEarned;
            await _matchRepository.UpdateParticipantScoreAsync(participant.Id, newScore);

            _logger.LogInformation("[MATCH HUB] Answer processed - Correct: {IsCorrect}, Points: {Points}, New Score: {NewScore}", isCorrect, pointsEarned, newScore);

            // Get question number for notification
            var questionNumber = matchQuestion.QuestionOrder;

            // Notify opponent that this player answered
            var opponentId = matchSession.Participants
                .FirstOrDefault(p => p.ChildProfileId != childGuid)?.ChildProfileId;

            if (opponentId.HasValue)
            {
                await Clients.Group($"match_{matchId}")
                    .SendAsync("OpponentAnswered", questionNumber, isCorrect, newScore, childId.ToString());
                
                _logger.LogInformation("[MATCH HUB] Notified opponent - Question: {QuestionNumber}, Correct: {IsCorrect}", questionNumber, isCorrect);
            }

            // Check if both players answered THIS question
            var currentQuestionAnswerCount = 0;
            foreach (var p in matchSession.Participants)
            {
                var answered = await _matchRepository.GetAnswerAsync(p.Id, questionGuid);
                if (answered != null) currentQuestionAnswerCount++;
            }

            // When both players answered, signal everyone to advance to next question
            if (currentQuestionAnswerCount >= matchSession.Participants.Count)
            {
                _logger.LogInformation("[MATCH HUB] Both players answered question {QuestionNumber}, advancing...", questionNumber);
                await Clients.Group($"match_{matchId}").SendAsync("QuestionAdvance", questionNumber);
            }

            // Check if both players have answered all questions
            var allParticipants = matchSession.Participants.ToList();
            var totalQuestions = matchSession.Questions.Count;
            
            var allAnswersSubmitted = true;
            foreach (var p in allParticipants)
            {
                var answerCount = await _matchRepository.GetAnswerCountForParticipantAsync(p.Id);
                if (answerCount < totalQuestions)
                {
                    allAnswersSubmitted = false;
                    break;
                }
            }

            // If all answers submitted, complete the match
            // SemaphoreSlim per match → yalnızca bir thread tamamlar (race condition önlemi)
            if (allAnswersSubmitted)
            {
                var matchLock = _matchCompletionLocks.GetOrAdd(matchId, _ => new SemaphoreSlim(1, 1));
                if (!await matchLock.WaitAsync(0))
                {
                    // Başka thread zaten tamamlıyor
                    _logger.LogInformation("[MATCH HUB] Match {MatchId} completion already in progress, skipping", matchId);
                }
                else
                {
                    try
                    {
                        // Double-check: zaten completed ise tekrar işleme
                        var currentStatus = await _matchRepository.GetMatchStatusAsync(matchGuid);
                        if (currentStatus == MatchSessionStatus.Completed)
                        {
                            _logger.LogInformation("[MATCH HUB] Match {MatchId} already completed, skipping duplicate", matchId);
                        }
                        else
                        {
                            _logger.LogInformation("[MATCH HUB] All answers submitted, completing match {MatchId}", matchId);

                            // Reload fresh session
                            var freshSession = await _matchRepository.GetMatchSessionAsync(matchGuid, includeAll: true);
                            var freshParticipants = freshSession!.Participants.ToList();

                            // Kazananı cevaplar tablosundan hesapla (cached participant.Score'a güvenme —
                            // eş zamanlı SubmitAnswer çağrılarında stale olabilir)
                            var scoreByParticipant = new Dictionary<Guid, int>();
                            foreach (var p in freshParticipants)
                            {
                                scoreByParticipant[p.ChildProfileId] = await _matchRepository.GetScoreForParticipantAsync(p.Id);
                                // Participant.Score'u da güncelle (sonuç ekranı için)
                                await _matchRepository.UpdateParticipantScoreAsync(p.Id, scoreByParticipant[p.ChildProfileId]);
                            }

                            var topScore = scoreByParticipant.Values.Max();
                            var leaders = scoreByParticipant.Where(kvp => kvp.Value == topScore).ToList();
                            var winnerId = leaders.Count == 1 ? (Guid?)leaders[0].Key : null;

                            matchSession.Status = MatchSessionStatus.Completed;
                            matchSession.EndedAt = DateTime.UtcNow;
                            matchSession.WinnerId = winnerId;

                            await _matchRepository.UpdateMatchSessionAsync(matchSession);

                            // Update each participant's ChildProgress and TotalCoins
                            await UpdateMatchStatsAsync(freshParticipants, matchGuid);

                            // ── Canlı yarış istatistikleri + rozetleri (tüm oyuncular) ──
                            var liveBadgesByChild = await ApplyLiveMatchStatsAndAwardAsync(
                                freshParticipants, scoreByParticipant, winnerId, totalQuestions, matchId);

                            foreach (var p in freshParticipants)
                            {
                                try
                                {
                                    var cid = p.ChildProfileId;
                                    var earnedBadges = liveBadgesByChild.TryGetValue(cid, out var b)
                                        ? b : (IReadOnlyList<string>)Array.Empty<string>();

                                    // Kart ödülü yalnızca kazanana düşer
                                    CardDropResult? cardDrop = null;
                                    if (winnerId.HasValue && cid == winnerId.Value)
                                    {
                                        cardDrop = await _cardDropService.TryDropAsync(
                                            cid,
                                            "match_win",
                                            isGradeEligible: true,
                                            successPercent: 100,
                                            idempotencyKey: $"match:{matchId}:winner:{cid}");
                                    }

                                    if (earnedBadges.Count == 0 && cardDrop == null) continue;

                                    var connId = _connectionMatchMap
                                        .FirstOrDefault(kv =>
                                            kv.Value.ChildId == cid.ToString() &&
                                            kv.Value.MatchId == matchId)
                                        .Key;

                                    if (connId != null)
                                    {
                                        await Clients.Client(connId).SendAsync("MatchRewards", new
                                        {
                                            earnedBadges,
                                            cardDrop,
                                        });
                                        _logger.LogInformation("[MATCH] Rewards sent to {ChildId}: {BadgeCount} badges, card={Card}",
                                            cid, earnedBadges.Count, cardDrop?.CardName ?? "none");
                                    }
                                }
                                catch (Exception ex)
                                {
                                    _logger.LogError(ex, "[MATCH] Failed to send rewards to {ChildId}", p.ChildProfileId);
                                }
                            }

                            // Notify both players
                            await Clients.Group($"match_{matchId}").SendAsync("MatchCompleted", matchSession.Id);

                            var winnerName = winnerId.HasValue
                                ? freshParticipants.First(p => p.ChildProfileId == winnerId.Value).ChildProfile.Name
                                : "Draw";
                            _logger.LogInformation("[MATCH HUB] Match completed - Winner: {WinnerName}", winnerName);

                            // Lock'u temizle (maç bitti, artık gerekmez)
                            _matchCompletionLocks.TryRemove(matchId, out _);
                        }
                    }
                    finally
                    {
                        matchLock.Release();
                    }
                }
            }

            // Send success to caller
            await Clients.Caller.SendAsync("AnswerSubmitted", isCorrect, pointsEarned, newScore);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[MATCH HUB ERROR] {Message}", ex.Message);
            await Clients.Caller.SendAsync("Error", "Failed to submit answer");
        }
    }

    /// <summary>
    /// Player leaves/forfeits the match (explicit call from client)
    /// </summary>
    private async Task UpdateMatchStatsAsync(IReadOnlyList<MatchParticipant> participants, Guid matchGuid)
    {
        foreach (var participant in participants)
        {
            if (participant.Score <= 0) continue;

            try
            {
                var childId = participant.ChildProfileId;
                var opponentId = participants
                    .FirstOrDefault(p => p.ChildProfileId != childId)?.ChildProfileId;

                // Sıralama puanı anti-abuse: sınır aşılırsa oyun parası (coins) yine verilir
                // ama sıralama skoruna (TotalScore) eklenmez — Premium fazla maçla sıralama
                // avantajı kazanamaz.
                var rankingEligible = await IsLiveMatchRankingEligibleAsync(childId, opponentId, matchGuid);

                if (rankingEligible)
                {
                    // Update ChildProgress (sıralama metriği)
                    var progress = await _progressRepository.GetChildProgressAsync(childId);
                    if (progress == null)
                    {
                        await _progressRepository.CreateChildProgressAsync(new ChildProgress
                        {
                            Id = Guid.NewGuid(),
                            ChildId = childId,
                            TotalScore = participant.Score,
                            TotalStars = 0,
                            CompletedLevelsCount = 0
                        });
                    }
                    else
                    {
                        progress.TotalScore += participant.Score;
                        await _progressRepository.UpdateChildProgressAsync(progress);
                    }
                }

                // Oyun parası (TotalCoins) her durumda verilir.
                var childProfile = await _childProfileRepository.GetByIdAsync(childId);
                if (childProfile != null)
                {
                    childProfile.TotalCoins += participant.Score;
                    await _childProfileRepository.UpdateAsync(childProfile);
                }

                _logger.LogInformation("[MATCH HUB] Stats updated for child {ChildId}: +{Score} coins, rankingEligible={Eligible}",
                    childId, participant.Score, rankingEligible);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[MATCH HUB] Failed to update stats for participant {ParticipantId}", participant.Id);
            }
        }
    }

    /// <summary>
    /// Bu maçın çocuk için sıralama puanı (TotalScore) üretip üretmeyeceğini belirler:
    /// günün ilk 5 tamamlanan yarışı içinde ve aynı rakiple 2'den az maç yapılmışsa uygundur.
    /// </summary>
    private async Task<bool> IsLiveMatchRankingEligibleAsync(Guid childId, Guid? opponentId, Guid matchGuid)
    {
        var dayStartUtc = TurkeyTodayStartUtc();

        var totalToday = await _matchRepository
            .CountRankingLiveMatchesTodayAsync(childId, dayStartUtc, matchGuid);
        if (totalToday >= DailyRankingMatchCap)
            return false;

        if (opponentId.HasValue)
        {
            var vsOpponentToday = await _matchRepository
                .CountRankingLiveMatchesVsOpponentTodayAsync(childId, opponentId.Value, dayStartUtc, matchGuid);
            if (vsOpponentToday >= DailyRankingSameOpponentCap)
                return false;
        }

        return true;
    }

    /// <summary>İstanbul saatine göre bugünün başlangıcının (00:00) UTC karşılığı.</summary>
    private static DateTime TurkeyTodayStartUtc()
    {
        try
        {
            var zone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
            var nowLocal = TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone);
            var startLocal = DateTime.SpecifyKind(nowLocal.Date, DateTimeKind.Unspecified);
            return TimeZoneInfo.ConvertTimeToUtc(startLocal, zone);
        }
        catch (TimeZoneNotFoundException)
        {
            return DateTime.UtcNow.AddHours(3).Date.AddHours(-3);
        }
    }

    /// <summary>
    /// Canlı yarış sonucunu her oyuncu için profil istatistiklerine işler ve canlı yarış
    /// rozetlerini kontrol eder. Kazanana/kaybedene/beraberliğe göre sonuç kaydedilir.
    /// Sonuç: her çocuk için kazanılan rozet anahtarları.
    /// </summary>
    private async Task<Dictionary<Guid, IReadOnlyList<string>>> ApplyLiveMatchStatsAndAwardAsync(
        IReadOnlyList<MatchParticipant> participants,
        IReadOnlyDictionary<Guid, int> scoreByParticipant,
        Guid? winnerId,
        int totalQuestions,
        string matchId,
        bool byForfeit = false)
    {
        var result = new Dictionary<Guid, IReadOnlyList<string>>();
        if (!Guid.TryParse(matchId, out var matchGuid))
            return result;

        var categoryKey = await _matchRepository.GetMatchCategoryKeyAsync(matchGuid) ?? "genel";
        var maxScore = totalQuestions * 10; // her doğru cevap 10 puan

        foreach (var p in participants)
        {
            var cid = p.ChildProfileId;
            try
            {
                var score = scoreByParticipant.TryGetValue(cid, out var s) ? s : p.Score;

                GameOutcome outcome;
                bool won;
                if (winnerId == null)
                {
                    outcome = GameOutcome.Tie;
                    won = false;
                }
                else if (cid == winnerId.Value)
                {
                    outcome = GameOutcome.Win;
                    won = true;
                }
                else
                {
                    outcome = GameOutcome.Loss;
                    won = false;
                }

                // Kusursuz zafer yalnızca skorla kazanılan (hükmen olmayan) ve tüm soruların
                // doğru cevaplandığı maçlarda verilir.
                var perfectWin = won && !byForfeit && maxScore > 0 && score >= maxScore;
                var successPct = maxScore > 0 ? (int)Math.Round(score * 100.0 / maxScore) : 0;

                var snapshot = await _gameStatsRepository.ApplyResultAsync(
                    cid, "live_match", categoryKey, outcome, perfectWin, successPct);

                var totalWins = await _matchRepository.GetTotalWinsAsync(cid);
                var consecutiveWins = await _matchRepository.GetConsecutiveWinsAsync(cid);

                var badgeCtx = new BadgeTriggerContext
                {
                    MatchWon = won,
                    TotalMatchWins = totalWins,
                    ConsecutiveMatchWins = consecutiveWins,
                    LivePerfectWin = perfectWin,
                    // Geri dönüş yalnızca toplam skordan güvenilir şekilde çıkarılamaz; pasif bırakıldı.
                    LiveComebackWin = false,
                    TotalLiveMatchesPlayed = snapshot.TotalPlayed,
                    DistinctLiveCategoriesWon = snapshot.DistinctCategoriesWon,
                };

                var earned = await _badgeService.CheckAndAwardAsync(
                    cid, BadgeTrigger.MatchCompleted, badgeCtx);

                result[cid] = earned;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[MATCH] Failed to apply live match stats for {ChildId}", cid);
                result[cid] = Array.Empty<string>();
            }
        }

        return result;
    }

    public async Task LeaveMatch(string matchId)
    {
        // Prefer childId from map (set via JoinMatch) — claim may be absent for query-string JWT
        var childIdClaim = Context.User?.FindFirst("ChildId")?.Value;
        if (_connectionMatchMap.TryGetValue(Context.ConnectionId, out var entry))
        {
            childIdClaim = entry.ChildId;
        }

        if (childIdClaim != null)
        {
            _connectionMatchMap.TryRemove(Context.ConnectionId, out _);

            // Remove leaver from group first so only the remaining player receives OpponentLeft.
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"match_{matchId}");

            await ApplyForfeit(childIdClaim, matchId);
            _logger.LogInformation("[MATCH HUB] Client {ConnectionId} left match {MatchId}", Context.ConnectionId, matchId);
            return;
        }

        await LeaveMatchGroup(matchId);
    }

    private async Task ApplyForfeit(string childIdStr, string matchId)
    {
        try
        {
            if (!Guid.TryParse(childIdStr, out var childGuid) || !Guid.TryParse(matchId, out var matchGuid))
                return;

            _logger.LogInformation("[MATCH HUB] Player leaving match - Match: {MatchId}, Child: {ChildId}", matchId, childGuid);

            var matchSession = await _matchRepository.GetMatchSessionAsync(matchGuid, includeAll: true);
            if (matchSession == null || matchSession.Status == MatchSessionStatus.Completed || matchSession.Status == MatchSessionStatus.Abandoned)
                return;

            var opponent = matchSession.Participants.FirstOrDefault(p => p.ChildProfileId != childGuid);
            if (opponent != null)
            {
                matchSession.Status = MatchSessionStatus.Abandoned;
                matchSession.EndedAt = DateTime.UtcNow;
                matchSession.WinnerId = opponent.ChildProfileId;

                await _matchRepository.UpdateMatchSessionAsync(matchSession);

                // Award each participant their earned points
                await UpdateMatchStatsAsync(matchSession.Participants.ToList(), matchGuid);

                // ── Rozet + Kart ödülleri (kazanana) ────────────────────────
                var winnerId = opponent.ChildProfileId;
                try
                {
                    var totalQuestions = matchSession.Questions.Count;
                    var scoreByParticipant = matchSession.Participants
                        .ToDictionary(p => p.ChildProfileId, p => p.Score);

                    var liveBadgesByChild = await ApplyLiveMatchStatsAndAwardAsync(
                        matchSession.Participants.ToList(), scoreByParticipant, winnerId, totalQuestions, matchId, byForfeit: true);

                    var earnedBadges = liveBadgesByChild.TryGetValue(winnerId, out var wb)
                        ? wb : (IReadOnlyList<string>)Array.Empty<string>();

                    var cardDrop = await _cardDropService.TryDropAsync(
                        winnerId,
                        "match_win",
                        isGradeEligible: true,
                        successPercent: 100,
                        idempotencyKey: $"match:{matchId}:forfeit:{winnerId}");

                    var winnerConnId = _connectionMatchMap
                        .FirstOrDefault(kv =>
                            kv.Value.ChildId == winnerId.ToString() &&
                            kv.Value.MatchId == matchId)
                        .Key;

                    if (winnerConnId != null)
                    {
                        await Clients.Client(winnerConnId).SendAsync("MatchRewards", new
                        {
                            earnedBadges,
                            cardDrop,
                        });
                        _logger.LogInformation("[MATCH] Forfeit rewards sent to winner {WinnerId}: {BadgeCount} badges, card={Card}",
                            winnerId, earnedBadges.Count, cardDrop?.CardName ?? "none");
                    }
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "[MATCH] Failed to award forfeit rewards to winner {WinnerId}", winnerId);
                }

                await Clients.Group($"match_{matchId}").SendAsync("OpponentLeft");

                _logger.LogInformation("[MATCH HUB] Opponent wins by forfeit");
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[MATCH HUB ERROR] ApplyForfeit: {Message}", ex.Message);
        }
    }
}
