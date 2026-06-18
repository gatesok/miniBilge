using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;

namespace MiniBilge.Application.Services;

public class EducationService : IEducationService
{
    private readonly IEducationRepository _educationRepository;

    public EducationService(IEducationRepository educationRepository)
    {
        _educationRepository = educationRepository;
    }

    public async Task<List<SubjectDto>> GetAllSubjectsAsync()
    {
        var subjects = await _educationRepository.GetAllSubjectsAsync();

        return subjects.Select(s => new SubjectDto
        {
            Id = s.Id,
            Name = s.Name,
            DisplayOrder = s.DisplayOrder,
            IsActive = s.IsActive
        }).ToList();
    }

    public async Task<List<TopicDto>> GetTopicsBySubjectIdAsync(Guid subjectId)
    {
        var topics = await _educationRepository.GetTopicsBySubjectIdAsync(subjectId);

        return topics.Select(t => new TopicDto
        {
            Id = t.Id,
            SubjectId = t.SubjectId,
            Name = t.Name,
            Description = t.Description,
            DisplayOrder = t.DisplayOrder,
            IsActive = t.IsActive,
            GradeLevel = t.GradeLevel.HasValue ? (int)t.GradeLevel.Value : 0,
            EnglishLevel = t.EnglishLevel.HasValue ? (int)t.EnglishLevel.Value : null
        }).ToList();
    }

    public async Task<List<LevelDto>> GetLevelsByTopicIdAsync(Guid topicId)
    {
        var levels = await _educationRepository.GetLevelsByTopicIdAsync(topicId);

        return levels.Select(l => new LevelDto
        {
            Id = l.Id,
            TopicId = l.TopicId,
            Name = l.Name,
            Description = l.Description,
            Difficulty = l.Difficulty,
            DisplayOrder = l.DisplayOrder,
            MinCorrectToPass = l.MinCorrectToPass,
            IsActive = l.IsActive
        }).ToList();
    }

    public async Task<List<QuestionDto>> GetQuestionsByLevelIdAsync(Guid levelId, int count = 10)
    {
        var selectedQuestions = await _educationRepository.GetQuestionsByLevelIdAsync(levelId, count);

        return selectedQuestions.Select(q => new QuestionDto
        {
            Id = q.Id,
            LevelId = q.LevelId,
            QuestionText = q.QuestionText,
            QuestionType = q.QuestionType,
            Explanation = q.Explanation,
            Options = q.Options
                .OrderBy(o => o.DisplayOrder)
                .Select(o => new QuestionOptionDto
                {
                    Id = o.Id,
                    OptionText = o.OptionText,
                    DisplayOrder = o.DisplayOrder
                }).ToList()
        }).ToList();
    }

    public async Task<SubmitAnswerResponse> SubmitAnswerAsync(SubmitAnswerRequest request)
    {
        var question = await _educationRepository.GetQuestionByIdAsync(request.QuestionId);

        if (question == null)
        {
            throw new Exception("Soru bulunamadı");
        }

        var isCorrect = string.Equals(
            question.CorrectAnswer.Trim(),
            request.UserAnswer.Trim(),
            StringComparison.OrdinalIgnoreCase
        );

        return new SubmitAnswerResponse
        {
            IsCorrect = isCorrect,
            CorrectAnswer = question.CorrectAnswer,
            Explanation = question.Explanation
        };
    }
}
