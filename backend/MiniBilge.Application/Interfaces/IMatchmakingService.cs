using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces;

public interface IMatchmakingService
{
    /// <summary>
    /// Requests a match for a child. If a suitable opponent is found, creates a match session.
    /// Otherwise, adds the request to the queue.
    /// </summary>
    Task<MatchRequest> RequestMatchAsync(Guid childId, Guid? subjectId = null);
    
    /// <summary>
    /// Cancels an active match request for a child.
    /// </summary>
    Task<bool> CancelMatchRequestAsync(Guid childId);
    
    /// <summary>
    /// Creates a match session between two match requests.
    /// </summary>
    Task<MatchSession> CreateMatchAsync(MatchRequest request1, MatchRequest request2, Guid? subjectId = null);
    
    /// <summary>
    /// Expires old match requests that have exceeded the timeout period.
    /// </summary>
    Task ExpireOldRequestsAsync(int timeoutSeconds = 60);

    /// <summary>
    /// Davet kabul edilince iki oyuncu arasında direkt maç oluşturur.
    /// </summary>
    Task<MatchSession> CreateDirectMatchAsync(Guid inviterId, Guid inviteeId, Guid? subjectId);
}
