using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IPodcastQuizRepository
{
    Task<List<PodcastQuestion>> GetQuestionsWithOptionsAsync(Guid episodeId);
    Task<PodcastQuizResult?> GetResultAsync(Guid childProfileId, Guid episodeId);
    Task AddResultAsync(PodcastQuizResult result);
    Task UpdateResultAsync(PodcastQuizResult result);
    Task<bool> HasCompletedAsync(Guid childProfileId, Guid episodeId);
    Task SaveChangesAsync();
}
