using MiniBilge.Application.DTOs.Education;

namespace MiniBilge.Application.Interfaces;

public interface IEducationService
{
    // Subjects
    Task<List<SubjectDto>> GetAllSubjectsAsync();
    
    // Topics
    Task<List<TopicDto>> GetTopicsBySubjectIdAsync(Guid subjectId);
    
    // Levels
    Task<List<LevelDto>> GetLevelsByTopicIdAsync(Guid topicId);
    
    // Questions
    Task<List<QuestionDto>> GetQuestionsByLevelIdAsync(Guid levelId, int count = 10);
    
    // Answer submission
    Task<SubmitAnswerResponse> SubmitAnswerAsync(SubmitAnswerRequest request);
}
