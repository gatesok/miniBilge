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
}
