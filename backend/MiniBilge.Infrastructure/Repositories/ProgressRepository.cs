using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class ProgressRepository : IProgressRepository
{
    private readonly ApplicationDbContext _context;

    public ProgressRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // ChildProgress
    public async Task<ChildProgress?> GetChildProgressAsync(Guid childId)
    {
        return await _context.ChildProgresses
            .FirstOrDefaultAsync(cp => cp.ChildId == childId && !cp.IsDeleted);
    }

    public async Task<ChildProgress> CreateChildProgressAsync(ChildProgress childProgress)
    {
        _context.ChildProgresses.Add(childProgress);
        await _context.SaveChangesAsync();
        return childProgress;
    }

    public async Task<ChildProgress> UpdateChildProgressAsync(ChildProgress childProgress)
    {
        _context.ChildProgresses.Update(childProgress);
        await _context.SaveChangesAsync();
        return childProgress;
    }

    // LevelResult
    public async Task<LevelResult?> GetLevelResultAsync(Guid childId, Guid levelId)
    {
        return await _context.LevelResults
            .FirstOrDefaultAsync(lr => lr.ChildId == childId && lr.LevelId == levelId && !lr.IsDeleted);
    }

    public async Task<List<LevelResult>> GetLevelResultsByChildIdAsync(Guid childId)
    {
        return await _context.LevelResults
            .Where(lr => lr.ChildId == childId && !lr.IsDeleted)
            .OrderByDescending(lr => lr.CompletedAt)
            .ToListAsync();
    }

    public async Task<LevelResult> CreateLevelResultAsync(LevelResult levelResult)
    {
        _context.LevelResults.Add(levelResult);
        await _context.SaveChangesAsync();
        return levelResult;
    }

    public async Task<LevelResult> UpdateLevelResultAsync(LevelResult levelResult)
    {
        _context.LevelResults.Update(levelResult);
        await _context.SaveChangesAsync();
        return levelResult;
    }

    // AnswerAttempt
    public async Task<AnswerAttempt> CreateAnswerAttemptAsync(AnswerAttempt answerAttempt)
    {
        _context.AnswerAttempts.Add(answerAttempt);
        await _context.SaveChangesAsync();
        return answerAttempt;
    }

    public async Task<List<AnswerAttempt>> GetAnswerAttemptsByChildIdAsync(Guid childId)
    {
        return await _context.AnswerAttempts
            .Where(aa => aa.ChildId == childId && !aa.IsDeleted)
            .OrderByDescending(aa => aa.AttemptedAt)
            .ToListAsync();
    }

    public async Task<List<AnswerAttempt>> GetAnswerAttemptsWithTopicAsync(Guid childId)
    {
        return await _context.AnswerAttempts
            .Include(aa => aa.Question)
                .ThenInclude(q => q.Level)
                    .ThenInclude(l => l.Topic)
                        .ThenInclude(t => t.Subject)
            .Where(aa => aa.ChildId == childId && !aa.IsDeleted)
            .ToListAsync();
    }

    public async Task<List<AnswerAttempt>> GetAnswerAttemptsByDateRangeAsync(Guid childId, DateTime start, DateTime end)
    {
        return await _context.AnswerAttempts
            .Include(aa => aa.Question)
                .ThenInclude(q => q.Level)
                    .ThenInclude(l => l.Topic)
                        .ThenInclude(t => t.Subject)
            .Where(aa => aa.ChildId == childId && !aa.IsDeleted
                      && aa.AttemptedAt >= start && aa.AttemptedAt < end)
            .OrderBy(aa => aa.AttemptedAt)
            .ToListAsync();
    }

    public async Task<List<LevelResult>> GetLevelResultsByDateRangeAsync(Guid childId, DateTime start, DateTime end)
    {
        return await _context.LevelResults
            .Where(lr => lr.ChildId == childId && !lr.IsDeleted
                      && lr.CompletedAt.HasValue
                      && lr.CompletedAt.Value >= start && lr.CompletedAt.Value < end)
            .OrderBy(lr => lr.CompletedAt)
            .ToListAsync();
    }

    // Tüm progress'leri döner (Leaderboard için)
    public async Task<List<ChildProgress>> GetAllProgressAsync(CancellationToken cancellationToken = default)
    {
        return await _context.ChildProgresses
            .Where(cp => !cp.IsDeleted)
            .ToListAsync(cancellationToken);
    }

    // MatchAnswer — tarih aralığına göre (rapor için)
    public async Task<List<MatchAnswer>> GetMatchAnswersByDateRangeAsync(Guid childId, DateTime start, DateTime end)
    {
        return await _context.MatchAnswers
            .Include(ma => ma.Participant)
            .Include(ma => ma.Question)
                .ThenInclude(q => q.Level)
                    .ThenInclude(l => l.Topic)
                        .ThenInclude(t => t.Subject)
            .Where(ma => ma.Participant.ChildProfileId == childId
                      && ma.AnsweredAt >= start && ma.AnsweredAt < end)
            .OrderBy(ma => ma.AnsweredAt)
            .ToListAsync();
    }

    // MatchAnswer — konu analizi için (zayıf konular)
    public async Task<List<MatchAnswer>> GetMatchAnswersWithTopicAsync(Guid childId)
    {
        return await _context.MatchAnswers
            .Include(ma => ma.Participant)
            .Include(ma => ma.Question)
                .ThenInclude(q => q.Level)
                    .ThenInclude(l => l.Topic)
                        .ThenInclude(t => t.Subject)
            .Where(ma => ma.Participant.ChildProfileId == childId)
            .ToListAsync();
    }
}
