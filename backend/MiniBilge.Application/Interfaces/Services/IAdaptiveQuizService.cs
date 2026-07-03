using MiniBilge.Application.DTOs.AdaptiveQuiz;

namespace MiniBilge.Application.Interfaces.Services;

public interface IAdaptiveQuizService
{
    /// <summary>Çocuğun son 30 günlük performansına göre zayıf konuları döner.</summary>
    Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId);

    /// <summary>GPT-4o-mini ile belirtilen konu için sorular üretir (24h cache'li).</summary>
    Task<List<AdaptiveQuestionDto>> GenerateQuestionsAsync(
        Guid childId, GenerateAdaptiveQuestionsRequest request);

    /// <summary>Çocuğun verdiği cevabı kaydeder.</summary>
    Task SubmitAnswerAsync(Guid childId, SubmitAdaptiveAnswerRequest request);
}
