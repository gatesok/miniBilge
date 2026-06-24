using MiniBilge.Application.DTOs.Education;

namespace MiniBilge.Application.Interfaces;

public interface ITopicExplanationService
{
    Task<TopicExplanationDto> ExplainTopicAsync(ExplainTopicRequest request);
}
