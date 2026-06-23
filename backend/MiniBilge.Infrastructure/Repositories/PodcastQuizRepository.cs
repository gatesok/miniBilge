using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class PodcastQuizRepository : IPodcastQuizRepository
{
    private readonly ApplicationDbContext _context;

    public PodcastQuizRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<PodcastQuestion>> GetQuestionsWithOptionsAsync(Guid episodeId)
        => await _context.PodcastQuestions
            .AsNoTracking()
            .Where(q => q.EpisodeId == episodeId && q.IsActive && !q.IsDeleted)
            .OrderBy(q => q.DisplayOrder)
            .Include(q => q.Options.Where(o => !o.IsDeleted).OrderBy(o => o.DisplayOrder))
            .ToListAsync();

    public async Task<PodcastQuizResult?> GetResultAsync(Guid childProfileId, Guid episodeId)
        => await _context.PodcastQuizResults
            .FirstOrDefaultAsync(r => r.ChildProfileId == childProfileId
                                   && r.EpisodeId == episodeId
                                   && !r.IsDeleted);

    public async Task AddResultAsync(PodcastQuizResult result)
        => await _context.PodcastQuizResults.AddAsync(result);

    public Task UpdateResultAsync(PodcastQuizResult result)
    {
        _context.PodcastQuizResults.Update(result);
        return Task.CompletedTask;
    }

    public async Task<bool> HasCompletedAsync(Guid childProfileId, Guid episodeId)
        => await _context.PodcastQuizResults
            .AnyAsync(r => r.ChildProfileId == childProfileId
                        && r.EpisodeId == episodeId
                        && !r.IsDeleted);

    public async Task SaveChangesAsync()
        => await _context.SaveChangesAsync();
}
