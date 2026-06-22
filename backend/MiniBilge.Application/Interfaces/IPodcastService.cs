using MiniBilge.Application.DTOs.Podcast;

namespace MiniBilge.Application.Interfaces;

public interface IPodcastService
{
    Task<IEnumerable<PodcastEpisodeSummaryDto>> GetEpisodesByLevelAsync(int englishLevel);
    Task<PodcastEpisodeDto?> GetEpisodeAsync(Guid episodeId);
}
