using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class MatchmakingService : IMatchmakingService
{
    private readonly IMatchRepository _matchRepository;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IEducationRepository _educationRepository;
    private readonly IMatchNotifier _matchNotifier;
    private const int QuestionsPerMatch = 5;
    private const int MaxLevelDifference = 1;
    public const int TimePerQuestion = 120;

    public MatchmakingService(
        IMatchRepository matchRepository,
        IChildProfileRepository childProfileRepository,
        IEducationRepository educationRepository,
        IMatchNotifier matchNotifier)
    {
        _matchRepository = matchRepository;
        _childProfileRepository = childProfileRepository;
        _educationRepository = educationRepository;
        _matchNotifier = matchNotifier;
    }

    public async Task<MatchRequest> RequestMatchAsync(Guid childId, Guid? subjectId = null)
    {
        Console.WriteLine($"[MATCHMAKING] RequestMatchAsync called for child: {childId}");
        
        // Check if child already has an active request
        var existingRequest = await _matchRepository.GetActiveMatchRequestByChildIdAsync(childId);
        if (existingRequest != null)
        {
            Console.WriteLine($"[MATCHMAKING] Child already has active request: {existingRequest.Id}");
            return existingRequest;
        }

        // Get child profile to determine grade level
        var childProfile = await _childProfileRepository.GetByIdAsync(childId);
        if (childProfile == null)
        {
            throw new InvalidOperationException("Child profile not found");
        }

        Console.WriteLine($"[MATCHMAKING] Child grade level: {childProfile.GradeLevel}, English level: {childProfile.EnglishLevel}");

        // Determine if this is an English match
        var subjects = await _educationRepository.GetAllSubjectsAsync(default);
        var englishSubject = subjects.FirstOrDefault(s => s.Name == "İngilizce");
        var isEnglishMatch = subjectId.HasValue && englishSubject != null && subjectId.Value == englishSubject.Id;

        // Create new match request (subjectId stored so filtering works when opponent arrives)
        var newRequest = await _matchRepository.CreateMatchRequestAsync(childId, subjectId);
        Console.WriteLine($"[MATCHMAKING] Created new match request: {newRequest.Id} (SubjectId: {subjectId})");

        // Try to find a suitable opponent (same subject, compatible level)
        List<MatchRequest> pendingRequests;
        if (isEnglishMatch && childProfile.EnglishLevel.HasValue)
        {
            pendingRequests = await _matchRepository.GetPendingMatchRequestsByEnglishLevelAsync(
                childProfile.EnglishLevel.Value,
                subjectId,
                MaxLevelDifference);
        }
        else
        {
            pendingRequests = await _matchRepository.GetPendingMatchRequestsAsync(
                childProfile.GradeLevel,
                subjectId,
                MaxLevelDifference);
        }

        Console.WriteLine($"[MATCHMAKING] Found {pendingRequests.Count} pending requests");
        foreach (var req in pendingRequests)
        {
            Console.WriteLine($"  - Request {req.Id}: Child {req.ChildProfileId}, Grade {req.ChildProfile?.GradeLevel}");
        }

        // Filter out the current child's request and find the oldest waiting request
        var opponent = pendingRequests
            .Where(r => r.ChildProfileId != childId)
            .OrderBy(r => r.RequestedAt)
            .FirstOrDefault();

        if (opponent != null)
        {
            Console.WriteLine($"[MATCHMAKING] Opponent found! Creating match between {childId} and {opponent.ChildProfileId}");
            
            // Match found! Create match session
            var matchSession = await CreateMatchAsync(newRequest, opponent, subjectId);
            
            // Notify both players
            await _matchNotifier.NotifyMatchFoundAsync(
                matchSession, 
                newRequest.ChildProfileId, 
                opponent.ChildProfileId);
        }
        else
        {
            Console.WriteLine($"[MATCHMAKING] No opponent found yet. Waiting...");
        }

        return newRequest;
    }

    public async Task<bool> CancelMatchRequestAsync(Guid childId)
    {
        var request = await _matchRepository.GetActiveMatchRequestByChildIdAsync(childId);
        if (request == null)
        {
            return false;
        }

        request.Status = MatchRequestStatus.Cancelled;
        await _matchRepository.UpdateMatchRequestAsync(request);
        return true;
    }

    public async Task<MatchSession> CreateMatchAsync(MatchRequest request1, MatchRequest request2, Guid? subjectId = null)
    {
        // Use the stored SubjectId from the request (most reliable source)
        var effectiveSubjectId = request1.SubjectId ?? request2.SubjectId ?? subjectId;
        var child1 = await _childProfileRepository.GetByIdAsync(request1.ChildProfileId);
        var child2 = await _childProfileRepository.GetByIdAsync(request2.ChildProfileId);

        if (child1 == null || child2 == null)
        {
            throw new InvalidOperationException("One or both child profiles not found");
        }

        // Determine appropriate level for questions
        var subjects = await _educationRepository.GetAllSubjectsAsync(default);
        var englishSubject = subjects.FirstOrDefault(s => s.Name == "İngilizce");
        var isEnglishMatch = effectiveSubjectId.HasValue && englishSubject != null && effectiveSubjectId.Value == englishSubject.Id;

        List<Question> questions;
        if (isEnglishMatch && child1.EnglishLevel.HasValue && child2.EnglishLevel.HasValue)
        {
            // English match: use lower English level between two players
            var minLevel = (EnglishLevel)Math.Min((int)child1.EnglishLevel.Value, (int)child2.EnglishLevel.Value);
            questions = await SelectEnglishMatchQuestionsAsync(englishSubject!.Id, minLevel);
        }
        else if (isEnglishMatch)
        {
            // One or both don't have English level set — use A1 as default
            var level = child1.EnglishLevel ?? child2.EnglishLevel ?? EnglishLevel.A1;
            questions = await SelectEnglishMatchQuestionsAsync(englishSubject!.Id, level);
        }
        else
        {
            // Math (or other subject) match: use grade level logic
            var mathSubjectId = effectiveSubjectId;
            var minGrade = Math.Min((int)child1.GradeLevel, (int)child2.GradeLevel);
            var maxGrade = Math.Max((int)child1.GradeLevel, (int)child2.GradeLevel);
            var targetGradeLevel = (GradeLevel)Math.Max(minGrade, maxGrade - 1);
            questions = await SelectMatchQuestionsAsync(targetGradeLevel, mathSubjectId);
        }

        if (questions.Count < QuestionsPerMatch)
        {
            throw new InvalidOperationException($"Not enough questions available for the selected level");
        }

        // Create match session with participants and questions
        var matchSession = await _matchRepository.CreateMatchSessionAsync(
            request1, 
            request2, 
            questions.Select(q => q.Id).ToList());

        Console.WriteLine($"[MATCHMAKING] Match created: {matchSession.Id}");
        Console.WriteLine($"  Player 1: {child1.Name} (Grade {child1.GradeLevel}, English {child1.EnglishLevel})");
        Console.WriteLine($"  Player 2: {child2.Name} (Grade {child2.GradeLevel}, English {child2.EnglishLevel})");
        Console.WriteLine($"  Questions: {questions.Count}");

        return matchSession;
    }

    public async Task<MatchSession> CreateDirectMatchAsync(Guid inviterId, Guid inviteeId, Guid? subjectId)
    {
        var req1 = await _matchRepository.CreateMatchRequestAsync(inviterId, subjectId);
        var req2 = await _matchRepository.CreateMatchRequestAsync(inviteeId, subjectId);
        var matchSession = await CreateMatchAsync(req1, req2, subjectId);
        await _matchNotifier.NotifyMatchFoundAsync(matchSession, inviterId, inviteeId);
        return matchSession;
    }

    public async Task ExpireOldRequestsAsync(int timeoutSeconds = 60)
    {
        await _matchRepository.ExpireOldMatchRequestsAsync(timeoutSeconds);
    }

    private async Task<List<Question>> SelectEnglishMatchQuestionsAsync(Guid englishSubjectId, EnglishLevel englishLevel)
    {
        var topics = await _educationRepository.GetTopicsByEnglishLevelAsync(englishSubjectId, englishLevel);

        if (!topics.Any())
        {
            // Fallback: try one level lower
            var fallbackLevel = (EnglishLevel)Math.Max((int)englishLevel - 1, (int)EnglishLevel.A1);
            Console.WriteLine($"[MATCHMAKING] No English topics for {englishLevel}, falling back to {fallbackLevel}");
            topics = await _educationRepository.GetTopicsByEnglishLevelAsync(englishSubjectId, fallbackLevel);
        }

        if (!topics.Any())
        {
            throw new InvalidOperationException($"No English topics found for level {englishLevel}");
        }

        var allQuestions = new List<Question>();
        foreach (var topic in topics)
        {
            var levels = await _educationRepository.GetLevelsByTopicIdAsync(topic.Id, default);
            foreach (var level in levels)
            {
                var questions = await _educationRepository.GetQuestionsByLevelIdAsync(level.Id);
                allQuestions.AddRange(questions);
            }
        }

        if (allQuestions.Count < QuestionsPerMatch)
        {
            throw new InvalidOperationException($"Not enough English questions. Found {allQuestions.Count}, need {QuestionsPerMatch}");
        }

        var random = new Random();
        return allQuestions.OrderBy(q => random.Next()).Take(QuestionsPerMatch).ToList();
    }

    private async Task<List<Question>> SelectMatchQuestionsAsync(GradeLevel gradeLevel, Guid? subjectId = null)
    {
        // Use provided subjectId or fall back to Matematik
        var subjects = await _educationRepository.GetAllSubjectsAsync(default);
        var subject = subjectId.HasValue
            ? subjects.FirstOrDefault(s => s.Id == subjectId.Value)
            : subjects.FirstOrDefault(s => s.Name == "Matematik");
        
        if (subject == null)
        {
            throw new InvalidOperationException("Subject not found");
        }

        // Get topics filtered by grade level
        var topics = await _educationRepository.GetTopicsByGradeLevelAsync(subject.Id, gradeLevel);

        // Fallback: if no topics found for the target grade, try one grade higher
        if (!topics.Any())
        {
            var fallbackGrade = (GradeLevel)Math.Min((int)gradeLevel + 1, (int)GradeLevel.Grade4);
            Console.WriteLine($"[MATCHMAKING] No topics found for {gradeLevel}, falling back to {fallbackGrade}");
            topics = await _educationRepository.GetTopicsByGradeLevelAsync(subject.Id, fallbackGrade);
        }

        if (!topics.Any())
        {
            throw new InvalidOperationException($"No topics found for grade level {gradeLevel} or higher");
        }

        var allQuestions = new List<Question>();

        foreach (var topic in topics)
        {
            var levels = await _educationRepository.GetLevelsByTopicIdAsync(topic.Id, default);
            foreach (var level in levels)
            {
                var questions = await _educationRepository.GetQuestionsByLevelIdAsync(level.Id);
                allQuestions.AddRange(questions);
            }
        }

        if (allQuestions.Count < QuestionsPerMatch)
        {
            throw new InvalidOperationException($"Not enough questions available. Found {allQuestions.Count}, need {QuestionsPerMatch}");
        }

        // Randomly select questions
        var random = new Random();
        var selectedQuestions = allQuestions
            .OrderBy(q => random.Next())
            .Take(QuestionsPerMatch)
            .ToList();

        return selectedQuestions;
    }
}
