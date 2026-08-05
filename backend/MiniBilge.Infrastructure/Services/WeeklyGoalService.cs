using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Options;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// P6-B04: Ebeveyn haftalık hedefi (çalışma dakikası + odak konu) yönetimi ve
/// mevcut haftanın ilerlemesinin hesaplanması.
/// </summary>
public class WeeklyGoalService : IWeeklyGoalService
{
    private readonly ApplicationDbContext _db;
    private readonly IProgressRepository _progressRepository;
    private readonly IAdultTournamentService _tournamentService;

    // Maç/meydan okuma için gerçek süre tutulmadığından tahmini kullanılır.
    private const int EstimatedSecondsPerQuestion = 15;
    private const int MaxSecondsPerMatchSession = 1800;

    public WeeklyGoalService(
        ApplicationDbContext db,
        IProgressRepository progressRepository,
        IAdultTournamentService tournamentService)
    {
        _db = db;
        _progressRepository = progressRepository;
        _tournamentService = tournamentService;
    }

    public async Task<WeeklyGoalDto> GetWeeklyGoalAsync(Guid childId)
    {
        var goal = await _db.ParentWeeklyGoals
            .AsNoTracking()
            .FirstOrDefaultAsync(g => g.ChildProfileId == childId && !g.IsDeleted);

        return await BuildDtoAsync(childId, goal);
    }

    public async Task<WeeklyGoalDto> SetWeeklyGoalAsync(Guid childId, int? weeklyStudyMinutesGoal, Guid? focusTopicId, string? focusCategoryKey)
    {
        var goal = await _db.ParentWeeklyGoals
            .FirstOrDefaultAsync(g => g.ChildProfileId == childId && !g.IsDeleted);

        if (goal == null)
        {
            goal = new ParentWeeklyGoal
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childId,
                CreatedAt = DateTime.UtcNow,
            };
            _db.ParentWeeklyGoals.Add(goal);
        }

        // Odak: konu ve eğlence kategorisi birbirini dışlar; kategori doluysa konu temizlenir.
        var categoryKey = string.IsNullOrWhiteSpace(focusCategoryKey) ? null : focusCategoryKey.Trim().ToLowerInvariant();

        goal.WeeklyStudyMinutesGoal = weeklyStudyMinutesGoal;
        goal.FocusCategoryKey = categoryKey;
        goal.FocusTopicId = categoryKey != null ? null : focusTopicId;
        goal.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        return await BuildDtoAsync(childId, goal);
    }

    private async Task<WeeklyGoalDto> BuildDtoAsync(Guid childId, ParentWeeklyGoal? goal)
    {
        var weekStart = GetCurrentWeekMonday();
        var weekEnd = weekStart.AddDays(7);

        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, weekStart, weekEnd);
        var studySeconds = attempts
            .Where(a => a.TimeTakenSeconds.HasValue)
            .Sum(a => a.TimeTakenSeconds!.Value);

        // Eğlence quizleri AnswerAttempt üretmez; süre ve soru sayısını ayrı tablodan ekle.
        var entertainment = await _progressRepository.GetEntertainmentActivitiesByDateRangeAsync(childId, weekStart, weekEnd);
        studySeconds += entertainment.Sum(e => e.DurationSeconds);
        var entertainmentQuestions = entertainment.Sum(e => e.QuestionCount);

        // İngilizce kelime oyunu da AnswerAttempt üretmez; aynı şekilde ayrı tablodan ekle.
        var vocab = await _progressRepository.GetEnglishVocabActivitiesByDateRangeAsync(childId, weekStart, weekEnd);
        studySeconds += vocab.Sum(e => e.DurationSeconds);
        var vocabQuestions = vocab.Sum(e => e.QuestionCount);

        // Canlı yarış (maç): her cevap bir soru. Süre tutulmadığından oturum içi
        // ilk-son cevap farkından tahmin edilir (tek cevaplı oturumda sabit tahmin).
        var matchAnswers = await _progressRepository.GetMatchAnswersByDateRangeAsync(childId, weekStart, weekEnd);
        var matchQuestions = matchAnswers.Count;
        var matchSeconds = matchAnswers
            .GroupBy(a => a.MatchSessionId)
            .Sum(g =>
            {
                var span = (int)(g.Max(x => x.AnsweredAt) - g.Min(x => x.AnsweredAt)).TotalSeconds;
                var estimate = span > 0 ? span : g.Count() * EstimatedSecondsPerQuestion;
                return Math.Clamp(estimate, 0, MaxSecondsPerMatchSession);
            });

        // Meydan okuma (challenge): soru-bazlı kayıt yok. Çocuğun bu hafta bitirdiği
        // düellolar; soru = TotalQuestions, süre = soru başına sabit tahmin.
        var challengeQuestions = await _db.Challenges
            .AsNoTracking()
            .Where(c => !c.IsDeleted &&
                ((c.ChallengerId == childId && c.ChallengerScore != null
                    && c.ChallengerDoneAt >= weekStart && c.ChallengerDoneAt < weekEnd)
                 || (c.ChallengeeId == childId && c.ChallengeeScore != null
                    && c.ChallengeeDoneAt >= weekStart && c.ChallengeeDoneAt < weekEnd)))
            .SumAsync(c => (int?)c.TotalQuestions) ?? 0;
        var challengeSeconds = challengeQuestions * EstimatedSecondsPerQuestion;

        studySeconds += matchSeconds + challengeSeconds;

        var studyMinutes = studySeconds / 60;

        string? focusTopicName = null;
        decimal? focusTopicSuccessRate = null;

        if (!string.IsNullOrWhiteSpace(goal?.FocusCategoryKey))
        {
            // Yetişkin: odak bir eğlence kategorisi. Başarı = bu haftaki doğru / cevaplanan.
            var key = goal.FocusCategoryKey!;
            if (EntertainmentTopics.All.TryGetValue(key, out var cfg))
                focusTopicName = cfg.Label;

            var stats = await _tournamentService.GetWeeklyCategoryStatsAsync(childId, key);
            if (stats is { AnsweredCount: > 0 })
                focusTopicSuccessRate = Math.Round((decimal)stats.CorrectCount / stats.AnsweredCount, 2);
        }
        else if (goal?.FocusTopicId is Guid topicId)
        {
            focusTopicName = await _db.Topics
                .AsNoTracking()
                .Where(t => t.Id == topicId)
                .Select(t => t.Name)
                .FirstOrDefaultAsync();

            var topicAttempts = attempts
                .Where(a => a.Question?.Level?.Topic?.Id == topicId)
                .ToList();

            if (topicAttempts.Count > 0)
            {
                focusTopicSuccessRate = Math.Round(
                    (decimal)topicAttempts.Count(a => a.IsCorrect) / topicAttempts.Count, 2);
            }
        }

        return new WeeklyGoalDto
        {
            ChildId = childId,
            WeeklyStudyMinutesGoal = goal?.WeeklyStudyMinutesGoal,
            FocusTopicId = goal?.FocusTopicId,
            FocusTopicName = focusTopicName,
            FocusCategoryKey = goal?.FocusCategoryKey,
            WeekStart = weekStart,
            WeekEnd = weekEnd,
            StudyMinutesThisWeek = studyMinutes,
            QuestionsThisWeek = attempts.Count + entertainmentQuestions + vocabQuestions + matchQuestions + challengeQuestions,
            FocusTopicSuccessRate = focusTopicSuccessRate,
        };
    }

    private static DateTime GetCurrentWeekMonday()
    {
        var today = DateTime.UtcNow.Date;
        int diff = (7 + (int)today.DayOfWeek - (int)DayOfWeek.Monday) % 7;
        return today.AddDays(-diff);
    }
}
