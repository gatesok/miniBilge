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
    private const int MaxLevelDifference = 10; // TODO: Restore to 1 after testing

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

    public async Task<MatchRequest> RequestMatchAsync(Guid childId)
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

        Console.WriteLine($"[MATCHMAKING] Child grade level: {childProfile.GradeLevel}");

        // Create new match request
        var newRequest = await _matchRepository.CreateMatchRequestAsync(childId);
        Console.WriteLine($"[MATCHMAKING] Created new match request: {newRequest.Id}");

        // Try to find a suitable opponent
        var pendingRequests = await _matchRepository.GetPendingMatchRequestsAsync(
            childProfile.GradeLevel, 
            MaxLevelDifference);

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
            var matchSession = await CreateMatchAsync(newRequest, opponent);
            
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

    public async Task<MatchSession> CreateMatchAsync(MatchRequest request1, MatchRequest request2)
    {
        // Get both child profiles
        var child1 = await _childProfileRepository.GetByIdAsync(request1.ChildProfileId);
        var child2 = await _childProfileRepository.GetByIdAsync(request2.ChildProfileId);

        if (child1 == null || child2 == null)
        {
            throw new InvalidOperationException("One or both child profiles not found");
        }

        // Determine appropriate grade level for questions (use the lower level to be fair)
        var targetGradeLevel = (GradeLevel)Math.Min((int)child1.GradeLevel, (int)child2.GradeLevel);

        // Select random questions for the match
        var questions = await SelectMatchQuestionsAsync(targetGradeLevel);

        if (questions.Count < QuestionsPerMatch)
        {
            throw new InvalidOperationException($"Not enough questions available for grade level {targetGradeLevel}");
        }

        // Create match session with participants and questions
        var matchSession = await _matchRepository.CreateMatchSessionAsync(
            request1, 
            request2, 
            questions.Select(q => q.Id).ToList());

        Console.WriteLine($"[MATCHMAKING] Match created: {matchSession.Id}");
        Console.WriteLine($"  Player 1: {child1.Name} (Grade {child1.GradeLevel})");
        Console.WriteLine($"  Player 2: {child2.Name} (Grade {child2.GradeLevel})");
        Console.WriteLine($"  Questions: {questions.Count} at Grade {targetGradeLevel}");

        return matchSession;
    }

    public async Task ExpireOldRequestsAsync(int timeoutSeconds = 60)
    {
        await _matchRepository.ExpireOldMatchRequestsAsync(timeoutSeconds);
    }

    private async Task<List<Question>> SelectMatchQuestionsAsync(GradeLevel gradeLevel)
    {
        // Get all subjects and find Mathematics
        var subjects = await _educationRepository.GetAllSubjectsAsync(default);
        var mathSubject = subjects.FirstOrDefault(s => s.Name == "Matematik");
        
        if (mathSubject == null)
        {
            throw new InvalidOperationException("Mathematics subject not found");
        }

        // Get all topics for the mathematics subject
        var topics = await _educationRepository.GetTopicsBySubjectIdAsync(mathSubject.Id, default);

        if (!topics.Any())
        {
            throw new InvalidOperationException("No mathematics topics found");
        }

        var allQuestions = new List<Question>();

        // Collect questions from all topics (simplified approach - can be optimized later)
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
