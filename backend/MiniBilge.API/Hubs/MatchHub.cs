using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
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
    private readonly ILogger<MatchHub> _logger;

    // Tracks which match each connection is in: connectionId → (childId, matchId)
    private static readonly ConcurrentDictionary<string, (string ChildId, string MatchId)> _connectionMatchMap = new();

    public MatchHub(
        IMatchRepository matchRepository,
        IProgressRepository progressRepository,
        IChildProfileRepository childProfileRepository,
        ILogger<MatchHub> logger)
    {
        _matchRepository = matchRepository;
        _progressRepository = progressRepository;
        _childProfileRepository = childProfileRepository;
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

            // If match already ended (opponent forfeited or both finished), just notify caller to navigate
            if (matchSession.Status == MatchSessionStatus.Abandoned ||
                matchSession.Status == MatchSessionStatus.Completed)
            {
                _logger.LogInformation("[MATCH HUB] SubmitAnswer on already-finished match {MatchId} (status: {Status}), notifying caller", matchId, matchSession.Status);
                await Clients.Caller.SendAsync("MatchCompleted", matchSession.Id);
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
            if (allAnswersSubmitted)
            {
                _logger.LogInformation("[MATCH HUB] All answers submitted, completing match {MatchId}", matchId);
                
                // Reload participants from DB to get up-to-date scores
                var freshSession = await _matchRepository.GetMatchSessionAsync(matchGuid, includeAll: true);
                var freshParticipants = freshSession!.Participants.ToList();
                
                // Determine winner based on fresh scores
                var topScore = freshParticipants.Max(p => p.Score);
                var leaders = freshParticipants.Where(p => p.Score == topScore).ToList();
                var winnerId = leaders.Count == 1 ? (Guid?)leaders[0].ChildProfileId : null;
                
                matchSession.Status = MatchSessionStatus.Completed;
                matchSession.EndedAt = DateTime.UtcNow;
                matchSession.WinnerId = winnerId;
                
                await _matchRepository.UpdateMatchSessionAsync(matchSession);

                // Update each participant's ChildProgress and TotalCoins
                await UpdateMatchStatsAsync(freshParticipants);

                // Notify both players
                await Clients.Group($"match_{matchId}").SendAsync("MatchCompleted", matchSession.Id);
                
                var winnerName = winnerId.HasValue
                    ? freshParticipants.First(p => p.ChildProfileId == winnerId.Value).ChildProfile.Name
                    : "Draw";
                _logger.LogInformation("[MATCH HUB] Match completed - Winner: {WinnerName}", winnerName);
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
    private async Task UpdateMatchStatsAsync(IEnumerable<MatchParticipant> participants)
    {
        foreach (var participant in participants)
        {
            if (participant.Score <= 0) continue;

            try
            {
                var childId = participant.ChildProfileId;

                // Update ChildProgress
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

                // Update ChildProfile.TotalCoins
                var childProfile = await _childProfileRepository.GetByIdAsync(childId);
                if (childProfile != null)
                {
                    childProfile.TotalCoins += participant.Score;
                    await _childProfileRepository.UpdateAsync(childProfile);
                }

                _logger.LogInformation("[MATCH HUB] Stats updated for child {ChildId}: +{Score} points", childId, participant.Score);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[MATCH HUB] Failed to update stats for participant {ParticipantId}", participant.Id);
            }
        }
    }

    public async Task LeaveMatch(string matchId)
    {
        var childIdClaim = Context.User?.FindFirst("ChildId")?.Value;
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
                await UpdateMatchStatsAsync(matchSession.Participants);

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
