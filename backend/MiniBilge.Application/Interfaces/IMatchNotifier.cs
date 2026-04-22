using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces;

public interface IMatchNotifier
{
    /// <summary>
    /// Notifies both players that a match has been found.
    /// </summary>
    Task NotifyMatchFoundAsync(MatchSession matchSession, Guid childId1, Guid childId2);
    
    /// <summary>
    /// Notifies a player that their opponent has answered a question.
    /// </summary>
    Task NotifyOpponentAnsweredAsync(Guid matchId, Guid recipientChildId, int questionNumber, bool isCorrect);
    
    /// <summary>
    /// Notifies a player that their opponent has left the match.
    /// </summary>
    Task NotifyOpponentLeftAsync(Guid matchId, Guid recipientChildId);
    
    /// <summary>
    /// Notifies both players that the match has been completed.
    /// </summary>
    Task NotifyMatchCompletedAsync(Guid matchId, Guid childId1, Guid childId2);
}
