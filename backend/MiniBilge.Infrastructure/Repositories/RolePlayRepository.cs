using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class RolePlayRepository : IRolePlayRepository
{
    private readonly ApplicationDbContext _context;

    public RolePlayRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<RolePlaySession> CreateSessionAsync(RolePlaySession session)
    {
        session.Id = Guid.NewGuid();
        session.CreatedAt = DateTime.UtcNow;
        _context.RolePlaySessions.Add(session);
        await _context.SaveChangesAsync();
        return session;
    }

    public async Task<RolePlaySession?> GetSessionAsync(Guid sessionId)
        => await _context.RolePlaySessions
            .FirstOrDefaultAsync(s => s.Id == sessionId);

    public async Task<List<RolePlayTurn>> GetTurnsAsync(Guid sessionId)
        => await _context.RolePlayTurns
            .Where(t => t.SessionId == sessionId)
            .OrderBy(t => t.CreatedAt)
            .ToListAsync();

    public async Task AddTurnAsync(RolePlayTurn turn)
    {
        turn.Id = Guid.NewGuid();
        turn.CreatedAt = DateTime.UtcNow;
        _context.RolePlayTurns.Add(turn);
        await _context.SaveChangesAsync();
    }

    public async Task IncrementTurnCountAsync(Guid sessionId)
    {
        await _context.RolePlaySessions
            .Where(s => s.Id == sessionId)
            .ExecuteUpdateAsync(s => s.SetProperty(x => x.TurnCount, x => x.TurnCount + 1));
    }

    public async Task CompleteSessionAsync(Guid sessionId, int score, string feedback)
    {
        await _context.RolePlaySessions
            .Where(s => s.Id == sessionId)
            .ExecuteUpdateAsync(s => s
                .SetProperty(x => x.Status, "completed")
                .SetProperty(x => x.TotalScore, score)
                .SetProperty(x => x.FinalFeedback, feedback)
                .SetProperty(x => x.CompletedAt, DateTime.UtcNow));
    }
}
