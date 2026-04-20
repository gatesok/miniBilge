using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IEducationRepository
{
    // Subjects
    Task<List<Subject>> GetAllSubjectsAsync(CancellationToken cancellationToken = default);
    
    // Topics
    Task<List<Topic>> GetTopicsBySubjectIdAsync(Guid subjectId, CancellationToken cancellationToken = default);
    
    // Levels
    Task<List<Level>> GetLevelsByTopicIdAsync(Guid topicId, CancellationToken cancellationToken = default);
    
    // Questions
    Task<List<Question>> GetQuestionsByLevelIdAsync(Guid levelId, CancellationToken cancellationToken = default);
    Task<Question?> GetQuestionByIdAsync(Guid questionId, CancellationToken cancellationToken = default);
}
