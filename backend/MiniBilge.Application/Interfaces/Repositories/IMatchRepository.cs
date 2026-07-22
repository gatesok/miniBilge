using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IMatchRepository
{
    // Match Request operations
    Task<MatchRequest> CreateMatchRequestAsync(Guid childId, Guid? subjectId = null, Guid? levelId = null,
        AdultCompetitionType? competitionType = null,
        string? competitionTopicKey = null,
        string? competitionDifficulty = null);
    Task<MatchRequest?> GetMatchRequestByIdAsync(Guid requestId);
    Task<MatchRequest?> GetActiveMatchRequestByChildIdAsync(Guid childId);
    Task<List<MatchRequest>> GetPendingMatchRequestsAsync(GradeLevel gradeLevel, Guid? subjectId = null, int levelRange = 1);
    Task<List<MatchRequest>> GetPendingMatchRequestsByEnglishLevelAsync(EnglishLevel englishLevel, Guid? subjectId = null, int levelRange = 1);
    Task<List<MatchRequest>> GetPendingMatchRequestsByLevelAsync(Guid levelId);
    Task<List<MatchRequest>> GetPendingAdultMatchRequestsAsync(
        AdultCompetitionType competitionType, string topicKey, string difficulty);
    Task UpdateMatchRequestAsync(MatchRequest matchRequest);
    Task DeleteMatchRequestAsync(Guid requestId);
    Task ExpireOldMatchRequestsAsync(int timeoutSeconds = 60);
    
    // Match Session operations
    Task<MatchSession> CreateMatchSessionAsync(MatchRequest request1, MatchRequest request2, List<Guid> questionIds);
    Task<MatchSession> CreateGeneratedMatchSessionAsync(
        MatchRequest request1, MatchRequest request2, Guid levelId,
        IReadOnlyList<MiniBilge.Application.DTOs.Entertainment.EntertainmentQuestionDto> questions);
    Task<MatchSession?> GetMatchSessionAsync(Guid matchId, bool includeAll = false);
    Task<MatchSession?> GetActiveMatchSessionByChildIdAsync(Guid childId);
    Task<List<MatchSession>> GetMatchHistoryAsync(Guid childId, int pageSize = 10, int pageNumber = 1);
    Task UpdateMatchSessionAsync(MatchSession matchSession);
    
    // Match Participant operations
    Task<MatchParticipant?> GetParticipantAsync(Guid matchId, Guid childId);
    Task UpdateParticipantScoreAsync(Guid participantId, int score);
    
    // Match Answer operations
    Task<MatchAnswer> SubmitAnswerAsync(Guid matchId, Guid participantId, Guid questionId, string answer, bool isCorrect, int pointsEarned);
    Task<MatchAnswer?> GetAnswerAsync(Guid participantId, Guid questionId);
    Task<int> GetAnswerCountForParticipantAsync(Guid participantId);
    Task<int> GetScoreForParticipantAsync(Guid participantId);
    Task<MatchSessionStatus?> GetMatchStatusAsync(Guid matchId);
    
    // Match Statistics
    Task<(int TotalMatches, int Wins, int Losses)> GetMatchStatsAsync(Guid childId);
}
