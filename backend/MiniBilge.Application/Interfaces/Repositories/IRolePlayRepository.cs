using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IRolePlayRepository
{
    Task<RolePlaySession> CreateSessionAsync(RolePlaySession session);
    Task<RolePlaySession?> GetSessionAsync(Guid sessionId);
    Task<List<RolePlayTurn>> GetTurnsAsync(Guid sessionId);
    Task AddTurnAsync(RolePlayTurn turn);
    Task IncrementTurnCountAsync(Guid sessionId);
    Task CompleteSessionAsync(Guid sessionId, int score, string feedback);
}
