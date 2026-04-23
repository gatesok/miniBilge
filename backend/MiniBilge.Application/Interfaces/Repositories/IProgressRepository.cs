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
    
    // Tüm progress'leri döner (Leaderboard için)
    Task<List<ChildProgress>> GetAllProgressAsync(CancellationToken cancellationToken = default);

    // AnswerAttempt
    Task<AnswerAttempt> CreateAnswerAttemptAsync(AnswerAttempt answerAttempt);
    Task<List<AnswerAttempt>> GetAnswerAttemptsByChildIdAsync(Guid childId);
    Task<List<AnswerAttempt>> GetAnswerAttemptsWithTopicAsync(Guid childId);
    Task<List<AnswerAttempt>> GetAnswerAttemptsByDateRangeAsync(Guid childId, DateTime start, DateTime end);

    // LevelResult (date-range)
    Task<List<LevelResult>> GetLevelResultsByDateRangeAsync(Guid childId, DateTime start, DateTime end);

    // MatchAnswer (maç cevapları — rapor için)
    Task<List<MatchAnswer>> GetMatchAnswersByDateRangeAsync(Guid childId, DateTime start, DateTime end);
    Task<List<MatchAnswer>> GetMatchAnswersWithTopicAsync(Guid childId);
}
