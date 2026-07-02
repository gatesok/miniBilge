using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class PodcastRepository : IPodcastRepository
{
    private readonly ApplicationDbContext _context;

    public PodcastRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<PodcastEpisode>> GetEpisodesByLevelAsync(EnglishLevel level)
        => await _context.PodcastEpisodes
            .Include(e => e.Lines)
            .Where(e => e.EnglishLevel == level && e.IsActive && !e.IsDeleted)
            .OrderBy(e => e.DisplayOrder)
            .ToListAsync();

    public async Task<PodcastEpisode?> GetEpisodeWithLinesAsync(Guid episodeId)
        => await _context.PodcastEpisodes
            .Include(e => e.Lines.OrderBy(l => l.DisplayOrder))
            .FirstOrDefaultAsync(e => e.Id == episodeId && e.IsActive && !e.IsDeleted);

    public async Task<IEnumerable<PodcastEpisode>> GetAllActiveAsync()
        => await _context.PodcastEpisodes
            .Include(e => e.Lines)
            .Where(e => e.IsActive && !e.IsDeleted)
            .OrderBy(e => e.EnglishLevel)
            .ThenBy(e => e.DisplayOrder)
            .ToListAsync();

    public async Task SaveLineAudioAsync(Guid lineId, string audioUrl, string voiceKey, CancellationToken ct = default)
    {
        await _context.PodcastLines
            .Where(l => l.Id == lineId)
            .ExecuteUpdateAsync(s => s
                .SetProperty(l => l.AudioUrl, audioUrl)
                .SetProperty(l => l.VoiceKey, voiceKey)
                .SetProperty(l => l.UpdatedAt, DateTime.UtcNow),
                ct);
    }

    public Task<int> GetCompletedQuizCountAsync(Guid childId)
        => _context.PodcastQuizResults
            .CountAsync(r => r.ChildProfileId == childId);
}
