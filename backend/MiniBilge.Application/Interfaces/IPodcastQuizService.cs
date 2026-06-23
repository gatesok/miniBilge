using MiniBilge.Application.DTOs.Podcast;

namespace MiniBilge.Application.Interfaces;

public interface IPodcastQuizService
{
    Task<List<PodcastQuestionDto>> GetQuestionsAsync(Guid episodeId);
    Task<PodcastQuizResultDto> SubmitQuizAsync(Guid childProfileId, Guid episodeId, PodcastQuizSubmitRequest request);
    Task<PodcastQuizResultDto?> GetLastResultAsync(Guid childProfileId, Guid episodeId);
    Task<bool> HasCompletedQuizAsync(Guid childProfileId, Guid episodeId);
}
