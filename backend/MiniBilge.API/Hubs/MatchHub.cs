using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.API.Hubs;

[Authorize]
public class MatchHub : Hub
{
    private readonly IMatchRepository _matchRepository;

    public MatchHub(IMatchRepository matchRepository)
    {
        _matchRepository = matchRepository;
    }

    public override async Task OnConnectedAsync()
    {
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            Console.WriteLine($"[MATCH HUB] Client connected: {childId}");
        }
        
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            Console.WriteLine($"[MATCH HUB] Client disconnected: {childId}");
        }
        
        await base.OnDisconnectedAsync(exception);
    }

    /// <summary>
    /// Client joins a specific match group
    /// </summary>
    public async Task JoinMatch(string matchId)
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, $"match_{matchId}");
        Console.WriteLine($"[MATCH HUB] Client {Context.ConnectionId} joined match {matchId}");
    }

    /// <summary>
    /// Client leaves a specific match group
    /// </summary>
    public async Task LeaveMatchGroup(string matchId)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, $"match_{matchId}");
        Console.WriteLine($"[MATCH HUB] Client {Context.ConnectionId} left match {matchId}");
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

            Console.WriteLine($"[MATCH HUB] Answer submitted - Match: {matchId}, Child: {childGuid}, Question: {questionId}, Answer: {answer}");

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

            Console.WriteLine($"[MATCH HUB] Answer processed - Correct: {isCorrect}, Points: {pointsEarned}, New Score: {newScore}");

            // Get question number for notification
            var questionNumber = matchQuestion.QuestionOrder;

            // Notify opponent that this player answered
            var opponentId = matchSession.Participants
                .FirstOrDefault(p => p.ChildProfileId != childGuid)?.ChildProfileId;

            if (opponentId.HasValue)
            {
                await Clients.Group($"match_{matchId}")
                    .SendAsync("OpponentAnswered", questionNumber, isCorrect, newScore, childId.ToString());
                
                Console.WriteLine($"[MATCH HUB] Notified opponent - Question: {questionNumber}, Correct: {isCorrect}");
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
                Console.WriteLine($"[MATCH HUB] Both players answered question {questionNumber}, advancing...");
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
                Console.WriteLine($"[MATCH HUB] All answers submitted, completing match {matchId}");
                
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

                // Notify both players
                await Clients.Group($"match_{matchId}").SendAsync("MatchCompleted", matchSession.Id);
                
                var winnerName = winnerId.HasValue
                    ? freshParticipants.First(p => p.ChildProfileId == winnerId.Value).ChildProfile.Name
                    : "Draw";
                Console.WriteLine($"[MATCH HUB] Match completed - Winner: {winnerName}");
            }

            // Send success to caller
            await Clients.Caller.SendAsync("AnswerSubmitted", isCorrect, pointsEarned, newScore);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MATCH HUB ERROR] {ex.Message}");
            await Clients.Caller.SendAsync("Error", "Failed to submit answer");
        }
    }

    /// <summary>
    /// Player leaves/forfeits the match
    /// </summary>
    public async Task LeaveMatch(string matchId)
    {
        try
        {
            var childIdClaim = Context.User?.FindFirst("ChildId")?.Value;
            if (childIdClaim == null || !Guid.TryParse(childIdClaim, out var childId))
            {
                return;
            }

            if (!Guid.TryParse(matchId, out var matchGuid))
            {
                return;
            }

            Console.WriteLine($"[MATCH HUB] Player leaving match - Match: {matchId}, Child: {childId}");

            var matchSession = await _matchRepository.GetMatchSessionAsync(matchGuid);
            if (matchSession == null)
            {
                return;
            }

            // Get opponent
            var opponent = matchSession.Participants
                .FirstOrDefault(p => p.ChildProfileId != childId);

            if (opponent != null)
            {
                // Set opponent as winner
                matchSession.Status = MatchSessionStatus.Abandoned;
                matchSession.EndedAt = DateTime.UtcNow;
                matchSession.WinnerId = opponent.ChildProfileId;
                
                await _matchRepository.UpdateMatchSessionAsync(matchSession);

                // Notify opponent
                await Clients.Group($"match_{matchId}").SendAsync("OpponentLeft");
                
                Console.WriteLine($"[MATCH HUB] Opponent wins by forfeit");
            }

            await LeaveMatchGroup(matchId);
        }
        catch (Exception ex)
        {
            Console.WriteLine($"[MATCH HUB ERROR] LeaveMatch: {ex.Message}");
        }
    }
}
