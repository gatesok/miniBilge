using MiniBilge.Application.DTOs.Entertainment;

namespace MiniBilge.Application.Interfaces.Services;

public interface IEntertainmentQuizService
{
    /// <summary>Tüm topic listesini döner.</summary>
    IReadOnlyList<EntertainmentTopicDto> GetTopics();

    /// <summary>Belirtilen topic ve zorlukta GPT ile soru üretir.</summary>
    Task<List<EntertainmentQuestionDto>> GenerateAsync(GenerateEntertainmentRequest request);
}
