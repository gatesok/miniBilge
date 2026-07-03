using MiniBilge.Application.DTOs.AdaptiveQuiz;

namespace MiniBilge.Application.Interfaces.Services;

public interface IAdaptiveQuizService
{
    Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId);
    Task<List<AdaptiveQuestionDto>> GenerateQuestionsAsync(Guid childId, GenerateAdaptiveQuestionsRequest request);
    Task SubmitAnswerAsync(Guid childId, SubmitAdaptiveAnswerRequest request);
    /// <summary>Quiz bitince yıldız/coin/kart/rozet verir.</summary>
    Task<AdaptiveQuizRewardDto> AwardAsync(Guid childId, AwardAdaptiveQuizRequest request);
}
