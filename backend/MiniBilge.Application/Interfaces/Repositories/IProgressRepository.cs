using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IProgressRepository
{
    // ChildProgress
    Task<ChildProgress?> GetChildProgressAsync(Guid childId);
    Task<ChildProgress> CreateChildProgressAsync(ChildProgress childProgress);
    Task<ChildProgress> UpdateChildProgressAsync(ChildProgress childProgress);
    
    // LevelResult
    Task<LevelResult?> GetLevelResultAsync(Guid childId, Guid levelId);
    Task<List<LevelResult>> GetLevelResultsByChildIdAsync(Guid childId);
    Task<LevelResult> CreateLevelResultAsync(LevelResult levelResult);
    Task<LevelResult> UpdateLevelResultAsync(LevelResult levelResult);
    
    // AnswerAttempt
    Task<AnswerAttempt> CreateAnswerAttemptAsync(AnswerAttempt answerAttempt);
    Task<List<AnswerAttempt>> GetAnswerAttemptsByChildIdAsync(Guid childId);
}
