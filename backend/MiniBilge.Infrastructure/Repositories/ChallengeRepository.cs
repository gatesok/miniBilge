using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class ChallengeRepository : IChallengeRepository
{
    private readonly ApplicationDbContext _context;

    public ChallengeRepository(ApplicationDbContext context)
        => _context = context;

    public async Task<Challenge> CreateAsync(Guid challengerId, Guid challengeeId, Guid levelId, DateTime expiresAt)
    {
        var challenge = new Challenge
        {
            ChallengerId   = challengerId,
            ChallengeeId   = challengeeId,
            LevelId        = levelId,
            Status         = ChallengeStatus.Pending,
            TotalQuestions = 10,
            ExpiresAt      = expiresAt,
            CreatedAt      = DateTime.UtcNow,
        };
        _context.Challenges.Add(challenge);
        await _context.SaveChangesAsync();
        return challenge;
    }

    public async Task<Challenge?> GetByIdAsync(Guid id)
        => await _context.Challenges
            .Include(c => c.Challenger)
            .Include(c => c.Challengee)
            .Include(c => c.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted);

    public async Task<List<Challenge>> GetIncomingAsync(Guid challengeeId)
        => await _context.Challenges
            .Include(c => c.Challenger)
            .Include(c => c.Challengee)
            .Include(c => c.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Where(c =>
                !c.IsDeleted &&
                c.ChallengeeId == challengeeId &&
                c.Status != ChallengeStatus.Completed &&
                c.Status != ChallengeStatus.Expired &&
                c.Status != ChallengeStatus.Declined &&
                c.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

    public async Task<List<Challenge>> GetOutgoingAsync(Guid challengerId)
        => await _context.Challenges
            .Include(c => c.Challenger)
            .Include(c => c.Challengee)
            .Include(c => c.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Where(c =>
                !c.IsDeleted &&
                c.ChallengerId == challengerId &&
                c.Status != ChallengeStatus.Completed &&
                c.Status != ChallengeStatus.Expired &&
                c.Status != ChallengeStatus.Declined)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

    public async Task<List<Challenge>> GetHistoryAsync(Guid childId)
        => await _context.Challenges
            .Include(c => c.Challenger)
            .Include(c => c.Challengee)
            .Include(c => c.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Where(c =>
                !c.IsDeleted &&
                (c.ChallengerId == childId || c.ChallengeeId == childId) &&
                (c.Status == ChallengeStatus.Completed ||
                 c.Status == ChallengeStatus.Expired   ||
                 c.Status == ChallengeStatus.Declined))
            .OrderByDescending(c => c.CreatedAt)
            .Take(50)
            .ToListAsync();

    public async Task<bool> HasActiveChallengeAsync(Guid challengerId, Guid challengeeId)
        => await _context.Challenges
            .AnyAsync(c =>
                !c.IsDeleted &&
                ((c.ChallengerId == challengerId && c.ChallengeeId == challengeeId) ||
                 (c.ChallengerId == challengeeId && c.ChallengeeId == challengerId)) &&
                c.Status != ChallengeStatus.Completed &&
                c.Status != ChallengeStatus.Expired   &&
                c.Status != ChallengeStatus.Declined  &&
                c.ExpiresAt > DateTime.UtcNow);

    public async Task UpdateAsync(Challenge challenge)
    {
        challenge.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public async Task UpdateReminderSentAtAsync(Guid challengeId, DateTime sentAt)
    {
        var challenge = await _context.Challenges.FindAsync(challengeId);
        if (challenge is null) return;
        challenge.LastReminderSentAt = sentAt;
        challenge.UpdatedAt          = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public async Task ExpireOldAsync()
    {
        var expirable = new[]
        {
            ChallengeStatus.Pending,
            ChallengeStatus.ChallengeeAccepted,
            ChallengeStatus.ChallengerDone,
        };

        var stale = await _context.Challenges
            .Where(c =>
                !c.IsDeleted &&
                expirable.Contains(c.Status) &&
                c.ExpiresAt <= DateTime.UtcNow)
            .ToListAsync();

        if (stale.Count == 0) return;

        foreach (var c in stale)
        {
            bool chalPlayed = c.ChallengerScore.HasValue;
            bool cheePlayed = c.ChallengeeScore.HasValue;

            if (chalPlayed && !cheePlayed)
            {
                // Challenger oynadı, challengee süreyi aştı → challenger kazanır
                c.ChallengeeScore = 0;
                c.Status          = ChallengeStatus.Completed;
            }
            else if (!chalPlayed && cheePlayed)
            {
                // Challengee oynadı, challenger süreyi aştı → challengee kazanır
                c.ChallengerScore = 0;
                c.Status          = ChallengeStatus.Completed;
            }
            else
            {
                // Kimse oynamadı veya her ikisi de oynamadı → süresi doldu
                c.Status = ChallengeStatus.Expired;
            }
            c.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }

    public async Task<(int Total, int Won, int Lost)> GetStatsAsync(Guid childId)
    {
        var completed = await _context.Challenges
            .Where(c =>
                !c.IsDeleted &&
                c.Status == ChallengeStatus.Completed &&
                (c.ChallengerId == childId || c.ChallengeeId == childId))
            .ToListAsync();

        var total = completed.Count;
        var won = completed.Count(c =>
            (c.ChallengerId == childId && (c.ChallengerScore ?? 0) > (c.ChallengeeScore ?? 0)) ||
            (c.ChallengeeId == childId && (c.ChallengeeScore ?? 0) > (c.ChallengerScore ?? 0)));
        var lost = completed.Count(c =>
            (c.ChallengerId == childId && (c.ChallengerScore ?? 0) < (c.ChallengeeScore ?? 0)) ||
            (c.ChallengeeId == childId && (c.ChallengeeScore ?? 0) < (c.ChallengerScore ?? 0)));

        return (total, won, lost);
    }
}
