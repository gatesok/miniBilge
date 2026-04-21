using MiniBilge.Application.DTOs.Progress;

namespace MiniBilge.Application.Interfaces;

public interface IProgressService
{
    // Calculation methods
    int CalculateScore(int correctCount, int totalQuestions, int? timeTakenSeconds = null);
    int CalculateStars(decimal successPercentage);
    Task<bool> CheckLevelUnlockAsync(Guid childId, Guid levelId);
    
    // Progress management
    Task SaveProgressAsync(SaveProgressRequest request);
    Task<ChildProgressDto> GetProgressAsync(Guid childId);
    Task SaveAnswerAttemptAsync(SaveAnswerAttemptRequest request);
    Task<List<LevelResultDto>> GetLevelResultsAsync(Guid childId);
}
