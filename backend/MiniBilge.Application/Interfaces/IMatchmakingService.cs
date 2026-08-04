using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces;

public interface IMatchmakingService
{
    /// <summary>
    /// Requests a match for a child. If a suitable opponent is found, creates a match session.
    /// Otherwise, adds the request to the queue.
    /// </summary>
    /// <param name="actingUserId">
    /// İşlemi yapan (kimliği doğrulanmış) ebeveyn kullanıcı. Canlı yarış günlük
    /// "live_match" kotasının kuyruğa girişte rezerve edilmesi için gereklidir.
    /// null geçilirse kota kontrolü uygulanmaz (geriye dönük uyumluluk).
    /// </param>
    Task<MatchRequest> RequestMatchAsync(Guid childId, Guid? subjectId = null, Guid? levelId = null,
        AdultCompetitionType? competitionType = null,
        string? competitionTopicKey = null,
        string? competitionDifficulty = null,
        Guid? actingUserId = null);
    
    /// <summary>
    /// Cancels an active match request for a child. actingUserId verilirse rezerve
    /// edilen canlı yarış hakkı iade edilir.
    /// </summary>
    Task<bool> CancelMatchRequestAsync(Guid childId, Guid? actingUserId = null);
    
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
