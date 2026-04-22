using Microsoft.AspNetCore.SignalR;
using MiniBilge.API.Hubs;
using MiniBilge.Application.Interfaces;
using MiniBilge.Domain.Entities;

namespace MiniBilge.API.Services;

public class MatchHubNotifier : IMatchNotifier
{
    private readonly IHubContext<MatchHub> _hubContext;

    public MatchHubNotifier(IHubContext<MatchHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public async Task NotifyMatchFoundAsync(MatchSession matchSession, Guid childId1, Guid childId2)
    {
        Console.WriteLine($"[MATCH HUB NOTIFIER] Match found notification: {matchSession.Id}");
        Console.WriteLine($"  Player 1: {childId1}");
        Console.WriteLine($"  Player 2: {childId2}");
        
        // Create match group
        var groupName = $"match_{matchSession.Id}";
        
        // Notify both players with just the match ID (to avoid circular reference issues)
        await _hubContext.Clients.All.SendAsync("MatchFound", new { 
            matchId = matchSession.Id.ToString(),
            status = matchSession.Status.ToString()
        });
        
        Console.WriteLine($"[MATCH HUB NOTIFIER] Match found notifications sent");
    }

    public async Task NotifyOpponentAnsweredAsync(Guid matchId, Guid recipientChildId, int questionNumber, bool isCorrect)
    {
        Console.WriteLine($"[MATCH HUB NOTIFIER] Opponent answered: Match {matchId}, Question {questionNumber}, Correct: {isCorrect}");
        
        var groupName = $"match_{matchId}";
        await _hubContext.Clients.Group(groupName)
            .SendAsync("OpponentAnswered", questionNumber, isCorrect);
    }

    public async Task NotifyOpponentLeftAsync(Guid matchId, Guid recipientChildId)
    {
        Console.WriteLine($"[MATCH HUB NOTIFIER] Opponent left: Match {matchId}");
        
        var groupName = $"match_{matchId}";
        await _hubContext.Clients.Group(groupName)
            .SendAsync("OpponentLeft");
    }

    public async Task NotifyMatchCompletedAsync(Guid matchId, Guid childId1, Guid childId2)
    {
        Console.WriteLine($"[MATCH HUB NOTIFIER] Match completed: {matchId}");
        
        var groupName = $"match_{matchId}";
        await _hubContext.Clients.Group(groupName)
            .SendAsync("MatchCompleted", matchId);
    }
}
