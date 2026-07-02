using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IPodcastRepository
{
    Task<IEnumerable<PodcastEpisode>> GetEpisodesByLevelAsync(EnglishLevel level);
    Task<PodcastEpisode?> GetEpisodeWithLinesAsync(Guid episodeId);
    Task<IEnumerable<PodcastEpisode>> GetAllActiveAsync();

    /// <summary>Satırın AudioUrl ve VoiceKey alanlarını kaydeder.</summary>
    Task SaveLineAudioAsync(Guid lineId, string audioUrl, string voiceKey, CancellationToken ct = default);

    /// <summary>Çocuğun tamamladığı podcast quiz sayısını döner.</summary>
    Task<int> GetCompletedQuizCountAsync(Guid childId);
}
