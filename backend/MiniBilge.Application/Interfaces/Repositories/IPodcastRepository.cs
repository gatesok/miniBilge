using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IPodcastRepository
{
    Task<IEnumerable<PodcastEpisode>> GetEpisodesByLevelAsync(EnglishLevel level);
    Task<PodcastEpisode?> GetEpisodeWithLinesAsync(Guid episodeId);
    Task<IEnumerable<PodcastEpisode>> GetAllActiveAsync();
}
