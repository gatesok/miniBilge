using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class MatchRepository : IMatchRepository
{
    private readonly ApplicationDbContext _context;

    public MatchRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // Match Request operations
    public async Task<MatchRequest> CreateMatchRequestAsync(Guid childId, Guid? subjectId = null, Guid? levelId = null,
        AdultCompetitionType? competitionType = null,
        string? competitionTopicKey = null,
        string? competitionDifficulty = null)
    {
        var matchRequest = new MatchRequest
        {
            ChildProfileId = childId,
            SubjectId = subjectId,
            LevelId = levelId,
            CompetitionType = competitionType,
            CompetitionTopicKey = competitionTopicKey,
            CompetitionDifficulty = competitionDifficulty,
            RequestedAt = DateTime.UtcNow,
            Status = MatchRequestStatus.Waiting
        };

        _context.MatchRequests.Add(matchRequest);
        await _context.SaveChangesAsync();

        return matchRequest;
    }

    public async Task<MatchRequest?> GetMatchRequestByIdAsync(Guid requestId)
    {
        return await _context.MatchRequests
            .Include(mr => mr.ChildProfile)
            .FirstOrDefaultAsync(mr => mr.Id == requestId);
    }

    public async Task<MatchRequest?> GetActiveMatchRequestByChildIdAsync(Guid childId)
    {
        return await _context.MatchRequests
            .Where(mr => mr.ChildProfileId == childId && mr.Status == MatchRequestStatus.Waiting)
            .OrderByDescending(mr => mr.RequestedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<List<MatchRequest>> GetPendingMatchRequestsAsync(GradeLevel gradeLevel, Guid? subjectId = null, int levelRange = 1)
    {
        var minLevel = (int)gradeLevel - levelRange;
        var maxLevel = (int)gradeLevel + levelRange;

        return await _context.MatchRequests
            .Include(mr => mr.ChildProfile)
            .Where(mr => mr.Status == MatchRequestStatus.Waiting)
            .Where(mr => mr.SubjectId == subjectId)
            .Where(mr => (int)mr.ChildProfile.GradeLevel >= minLevel && 
                        (int)mr.ChildProfile.GradeLevel <= maxLevel)
            .OrderBy(mr => mr.RequestedAt)
            .ToListAsync();
    }

    public async Task<List<MatchRequest>> GetPendingMatchRequestsByEnglishLevelAsync(EnglishLevel englishLevel, Guid? subjectId = null, int levelRange = 1)
    {
        var minLevel = (int)englishLevel - levelRange;
        var maxLevel = (int)englishLevel + levelRange;

        return await _context.MatchRequests
            .Include(mr => mr.ChildProfile)
            .Where(mr => mr.Status == MatchRequestStatus.Waiting)
            .Where(mr => mr.SubjectId == subjectId)
            .Where(mr => mr.ChildProfile.EnglishLevel.HasValue &&
                        (int)mr.ChildProfile.EnglishLevel.Value >= minLevel &&
                        (int)mr.ChildProfile.EnglishLevel.Value <= maxLevel)
            .OrderBy(mr => mr.RequestedAt)
            .ToListAsync();
    }

    public async Task<List<MatchRequest>> GetPendingAdultMatchRequestsAsync(
        AdultCompetitionType competitionType, string topicKey, string difficulty)
    {
        return await _context.MatchRequests
            .Include(mr => mr.ChildProfile)
            .Where(mr => mr.Status == MatchRequestStatus.Waiting)
            .Where(mr => mr.ChildProfile.GradeLevel == GradeLevel.Adult)
            .Where(mr => mr.CompetitionType == competitionType)
            .Where(mr => mr.CompetitionTopicKey == topicKey)
            .Where(mr => mr.CompetitionDifficulty == difficulty)
            .OrderBy(mr => mr.RequestedAt)
            .ToListAsync();
    }

    public async Task<List<MatchRequest>> GetPendingMatchRequestsByLevelAsync(Guid levelId)
    {
        return await _context.MatchRequests
            .Include(mr => mr.ChildProfile)
            .Where(mr => mr.Status == MatchRequestStatus.Waiting)
            .Where(mr => mr.LevelId == levelId)
            .OrderBy(mr => mr.RequestedAt)
            .ToListAsync();
    }

    public async Task UpdateMatchRequestAsync(MatchRequest matchRequest)
    {
        _context.MatchRequests.Update(matchRequest);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteMatchRequestAsync(Guid requestId)
    {
        var request = await _context.MatchRequests.FindAsync(requestId);
        if (request != null)
        {
            _context.MatchRequests.Remove(request);
            await _context.SaveChangesAsync();
        }
    }

    public async Task ExpireOldMatchRequestsAsync(int timeoutSeconds = 60)
    {
        var expiryTime = DateTime.UtcNow.AddSeconds(-timeoutSeconds);
        
        var expiredRequests = await _context.MatchRequests
            .Where(mr => mr.Status == MatchRequestStatus.Waiting && mr.RequestedAt < expiryTime)
            .ToListAsync();

        foreach (var request in expiredRequests)
        {
            request.Status = MatchRequestStatus.Expired;
        }

        await _context.SaveChangesAsync();
    }

    // Match Session operations
    public async Task<MatchSession> CreateMatchSessionAsync(MatchRequest request1, MatchRequest request2, List<Guid> questionIds)
    {
        var matchSession = new MatchSession
        {
            Status = MatchSessionStatus.Created
        };

        _context.MatchSessions.Add(matchSession);
        await _context.SaveChangesAsync();

        // Create participants
        var participant1 = new MatchParticipant
        {
            MatchSessionId = matchSession.Id,
            ChildProfileId = request1.ChildProfileId,
            JoinedAt = DateTime.UtcNow
        };

        var participant2 = new MatchParticipant
        {
            MatchSessionId = matchSession.Id,
            ChildProfileId = request2.ChildProfileId,
            JoinedAt = DateTime.UtcNow
        };

        _context.MatchParticipants.AddRange(participant1, participant2);

        // Create match questions
        for (int i = 0; i < questionIds.Count; i++)
        {
            var matchQuestion = new MatchQuestion
            {
                MatchSessionId = matchSession.Id,
                QuestionId = questionIds[i],
                QuestionOrder = i + 1
            };
            _context.MatchQuestions.Add(matchQuestion);
        }

        // Update match requests
        request1.Status = MatchRequestStatus.Matched;
        request1.MatchedAt = DateTime.UtcNow;
        request1.MatchSessionId = matchSession.Id;

        request2.Status = MatchRequestStatus.Matched;
        request2.MatchedAt = DateTime.UtcNow;
        request2.MatchSessionId = matchSession.Id;

        await _context.SaveChangesAsync();

        return matchSession;
    }

    public async Task<MatchSession> CreateGeneratedMatchSessionAsync(
        MatchRequest request1, MatchRequest request2, Guid levelId,
        IReadOnlyList<MiniBilge.Application.DTOs.Entertainment.EntertainmentQuestionDto> generated)
    {
        var questions = generated.Select((source, index) =>
        {
            var options = new[] { source.OptionA, source.OptionB, source.OptionC, source.OptionD };
            var question = new Question
            {
                Id = Guid.NewGuid(),
                LevelId = levelId,
                QuestionText = source.QuestionText,
                QuestionType = QuestionType.MultipleChoice,
                CorrectAnswer = source.CorrectAnswer,
                Explanation = source.Explanation,
                DisplayOrder = index,
                IsActive = false,
                CreatedAt = DateTime.UtcNow,
            };
            question.Options = options.Select((text, optionIndex) => new QuestionOption
            {
                Id = Guid.NewGuid(),
                QuestionId = question.Id,
                OptionText = text,
                DisplayOrder = optionIndex,
                CreatedAt = DateTime.UtcNow,
            }).ToList();
            return question;
        }).ToList();

        _context.Questions.AddRange(questions);
        await _context.SaveChangesAsync();
        return await CreateMatchSessionAsync(request1, request2, questions.Select(q => q.Id).ToList());
    }

    public async Task<MatchSession?> GetMatchSessionAsync(Guid matchId, bool includeAll = false)
    {
        var query = _context.MatchSessions
            .Include(ms => ms.Participants)
                .ThenInclude(p => p.ChildProfile)
            .AsQueryable();

        if (includeAll)
        {
            query = query
                .Include(ms => ms.Questions)
                    .ThenInclude(mq => mq.Question)
                        .ThenInclude(q => q.Options)
                .Include(ms => ms.Answers);
        }

        return await query.FirstOrDefaultAsync(ms => ms.Id == matchId);
    }

    public async Task<MatchSession?> GetActiveMatchSessionByChildIdAsync(Guid childId)
    {
        return await _context.MatchSessions
            .Include(ms => ms.Participants)
                .ThenInclude(p => p.ChildProfile)
            .Where(ms => ms.Participants.Any(p => p.ChildProfileId == childId))
            .Where(ms => ms.Status != MatchSessionStatus.Completed && ms.Status != MatchSessionStatus.Abandoned)
            .OrderByDescending(ms => ms.CreatedAt)
            .FirstOrDefaultAsync();
    }

    public async Task<List<MatchSession>> GetMatchHistoryAsync(Guid childId, int pageSize = 10, int pageNumber = 1)
    {
        return await _context.MatchSessions
            .Include(ms => ms.Participants)
                .ThenInclude(p => p.ChildProfile)
            .Where(ms => ms.Participants.Any(p => p.ChildProfileId == childId))
            .Where(ms => ms.Status == MatchSessionStatus.Completed || ms.Status == MatchSessionStatus.Abandoned)
            .OrderByDescending(ms => ms.CreatedAt)
            .Skip((pageNumber - 1) * pageSize)
            .Take(pageSize)
            .ToListAsync();
    }

    public async Task UpdateMatchSessionAsync(MatchSession matchSession)
    {
        _context.MatchSessions.Update(matchSession);
        await _context.SaveChangesAsync();
    }

    // Match Participant operations
    public async Task<MatchParticipant?> GetParticipantAsync(Guid matchId, Guid childId)
    {
        return await _context.MatchParticipants
            .Include(mp => mp.ChildProfile)
            .FirstOrDefaultAsync(mp => mp.MatchSessionId == matchId && mp.ChildProfileId == childId);
    }

    public async Task UpdateParticipantScoreAsync(Guid participantId, int score)
    {
        var participant = await _context.MatchParticipants.FindAsync(participantId);
        if (participant != null)
        {
            participant.Score = score;
            await _context.SaveChangesAsync();
        }
    }

    // Match Answer operations
    public async Task<MatchAnswer> SubmitAnswerAsync(Guid matchId, Guid participantId, Guid questionId, string answer, bool isCorrect, int pointsEarned)
    {
        var matchAnswer = new MatchAnswer
        {
            MatchSessionId = matchId,
            ParticipantId = participantId,
            QuestionId = questionId,
            Answer = answer,
            IsCorrect = isCorrect,
            AnsweredAt = DateTime.UtcNow,
            PointsEarned = pointsEarned
        };

        _context.MatchAnswers.Add(matchAnswer);
        await _context.SaveChangesAsync();

        return matchAnswer;
    }

    public async Task<MatchAnswer?> GetAnswerAsync(Guid participantId, Guid questionId)
    {
        return await _context.MatchAnswers
            .FirstOrDefaultAsync(ma => ma.ParticipantId == participantId && ma.QuestionId == questionId);
    }

    public async Task<int> GetAnswerCountForParticipantAsync(Guid participantId)
    {
        return await _context.MatchAnswers
            .CountAsync(ma => ma.ParticipantId == participantId);
    }

    /// <summary>
    /// Cevaplar tablosundan gerçek skoru toplar — cached participant.Score'dan
    /// bağımsız, race-condition'a karşı güvenli kazanan belirleme için kullanılır.
    /// </summary>
    public async Task<int> GetScoreForParticipantAsync(Guid participantId)
    {
        return await _context.MatchAnswers
            .Where(ma => ma.ParticipantId == participantId)
            .SumAsync(ma => ma.PointsEarned);
    }

    public async Task<MatchSessionStatus?> GetMatchStatusAsync(Guid matchId)
    {
        return await _context.MatchSessions
            .Where(ms => ms.Id == matchId)
            .Select(ms => (MatchSessionStatus?)ms.Status)
            .FirstOrDefaultAsync();
    }

    // Match Statistics
    public async Task<(int TotalMatches, int Wins, int Losses)> GetMatchStatsAsync(Guid childId)
    {
        var completedMatches = await _context.MatchSessions
            .Include(ms => ms.Participants)
            .Where(ms => ms.Participants.Any(p => p.ChildProfileId == childId))
            .Where(ms => ms.Status == MatchSessionStatus.Completed || ms.Status == MatchSessionStatus.Abandoned)
            .ToListAsync();

        var totalMatches = completedMatches.Count;
        var wins = completedMatches.Count(ms => ms.WinnerId != null && 
            ms.Participants.Any(p => p.ChildProfileId == childId && p.ChildProfileId == ms.WinnerId));
        var losses = completedMatches.Count(ms => ms.WinnerId != null &&
            !ms.Participants.Any(p => p.ChildProfileId == childId && p.ChildProfileId == ms.WinnerId));

        return (totalMatches, wins, losses);
    }
}
