using MiniBilge.Application.DTOs.Podcast;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class PodcastQuizService : IPodcastQuizService
{
    private readonly IPodcastQuizRepository _quizRepository;
    private readonly IChildProfileRepository _childProfileRepository;

    private const int RewardCoinsHigh   = 30;
    private const int RewardCoinsMid    = 20;
    private const int RewardCoinsLow    = 10;
    private const int RewardStarsHigh   = 3;
    private const int RewardStarsMid    = 2;
    private const int RewardStarsLow    = 1;

    public PodcastQuizService(
        IPodcastQuizRepository quizRepository,
        IChildProfileRepository childProfileRepository)
    {
        _quizRepository = quizRepository;
        _childProfileRepository = childProfileRepository;
    }

    public async Task<List<PodcastQuestionDto>> GetQuestionsAsync(Guid episodeId)
    {
        var questions = await _quizRepository.GetQuestionsWithOptionsAsync(episodeId);

        return questions.Select(q => new PodcastQuestionDto
        {
            Id = q.Id,
            QuestionText = q.QuestionText,
            QuestionType = q.QuestionType,
            DisplayOrder = q.DisplayOrder,
            Options = q.Options.Select(o => new PodcastQuestionOptionDto
            {
                Id = o.Id,
                OptionText = o.OptionText,
                DisplayOrder = o.DisplayOrder,
            }).ToList(),
        }).ToList();
    }

    public async Task<PodcastQuizResultDto> SubmitQuizAsync(
        Guid childProfileId, Guid episodeId, PodcastQuizSubmitRequest request)
    {
        var questions = await _quizRepository.GetQuestionsWithOptionsAsync(episodeId);

        var answerResults = new List<PodcastQuizAnswerResultDto>();
        int correctCount = 0;

        foreach (var answer in request.Answers)
        {
            var question = questions.FirstOrDefault(q => q.Id == answer.QuestionId);
            if (question is null) continue;

            bool isCorrect = string.Equals(
                answer.SelectedAnswer.Trim(),
                question.CorrectAnswer.Trim(),
                StringComparison.OrdinalIgnoreCase);

            if (isCorrect) correctCount++;

            answerResults.Add(new PodcastQuizAnswerResultDto
            {
                QuestionId = question.Id,
                IsCorrect = isCorrect,
                CorrectAnswer = question.CorrectAnswer,
                Explanation = question.Explanation,
            });
        }

        int totalQuestions = questions.Count;
        double successRate = totalQuestions > 0 ? (double)correctCount / totalQuestions : 0;

        bool isFirstCompletion = !await _quizRepository.HasCompletedAsync(childProfileId, episodeId);

        int coinsEarned = 0;
        int starsEarned = 0;

        if (isFirstCompletion)
        {
            (coinsEarned, starsEarned) = successRate >= 1.0
                ? (RewardCoinsHigh, RewardStarsHigh)
                : successRate >= 0.6
                    ? (RewardCoinsMid, RewardStarsMid)
                    : (RewardCoinsLow, RewardStarsLow);

            var child = await _childProfileRepository.GetByIdAsync(childProfileId);
            if (child is not null)
            {
                child.TotalCoins += coinsEarned;
                child.TotalStars += starsEarned;
                await _childProfileRepository.UpdateAsync(child);
            }

            await _quizRepository.AddResultAsync(new PodcastQuizResult
            {
                ChildProfileId = childProfileId,
                EpisodeId = episodeId,
                CorrectCount = correctCount,
                TotalQuestions = totalQuestions,
                CoinsEarned = coinsEarned,
                StarsEarned = starsEarned,
                CompletedAt = DateTime.UtcNow,
            });
        }
        else
        {
            var existing = await _quizRepository.GetResultAsync(childProfileId, episodeId);
            if (existing is not null)
            {
                existing.CorrectCount = correctCount;
                existing.TotalQuestions = totalQuestions;
                existing.CompletedAt = DateTime.UtcNow;
                existing.UpdatedAt = DateTime.UtcNow;
                await _quizRepository.UpdateResultAsync(existing);
            }
        }

        await _quizRepository.SaveChangesAsync();

        return new PodcastQuizResultDto
        {
            CorrectCount = correctCount,
            TotalQuestions = totalQuestions,
            StarsEarned = starsEarned,
            CoinsEarned = coinsEarned,
            IsFirstCompletion = isFirstCompletion,
            AnswerResults = answerResults,
        };
    }

    public async Task<PodcastQuizResultDto?> GetLastResultAsync(Guid childProfileId, Guid episodeId)
    {
        var result = await _quizRepository.GetResultAsync(childProfileId, episodeId);
        if (result is null) return null;

        return new PodcastQuizResultDto
        {
            CorrectCount = result.CorrectCount,
            TotalQuestions = result.TotalQuestions,
            StarsEarned = result.StarsEarned,
            CoinsEarned = result.CoinsEarned,
            IsFirstCompletion = false,
            AnswerResults = new(),
        };
    }

    public async Task<bool> HasCompletedQuizAsync(Guid childProfileId, Guid episodeId)
        => await _quizRepository.HasCompletedAsync(childProfileId, episodeId);
}
