using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;

namespace MiniBilge.Application.Services;

public class ParentReportingService : IParentReportingService
{
    private readonly IProgressRepository _progressRepository;

    public ParentReportingService(IProgressRepository progressRepository)
    {
        _progressRepository = progressRepository;
    }

    public async Task<DailySummaryDto> GetDailySummaryAsync(Guid childId, DateTime date)
    {
        var dayStart = date.Date;
        var dayEnd = dayStart.AddDays(1);

        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, dayStart, dayEnd);
        var matchAnswers = await _progressRepository.GetMatchAnswersByDateRangeAsync(childId, dayStart, dayEnd);
        var levelResults = await _progressRepository.GetLevelResultsByDateRangeAsync(childId, dayStart, dayEnd);

        // Solo + maç cevaplarını birleştir
        var correct = attempts.Count(a => a.IsCorrect) + matchAnswers.Count(a => a.IsCorrect);
        var wrong = attempts.Count(a => !a.IsCorrect) + matchAnswers.Count(a => !a.IsCorrect);
        var total = attempts.Count + matchAnswers.Count;

        // Puanlar: solo → LevelResult.Score, maç → MatchAnswer.PointsEarned toplamı
        var matchPoints = matchAnswers.Sum(a => a.PointsEarned);

        // Derse göre breakdown
        var subjectItems = attempts
            .Where(a => a.Question?.Level?.Topic?.Subject != null)
            .Select(a => (SubjectName: a.Question!.Level!.Topic!.Subject!.Name, a.IsCorrect))
            .Concat(matchAnswers
                .Where(a => a.Question?.Level?.Topic?.Subject != null)
                .Select(a => (SubjectName: a.Question!.Level!.Topic!.Subject!.Name, a.IsCorrect)));

        var subjectBreakdown = subjectItems
            .GroupBy(x => x.SubjectName)
            .Select(g =>
            {
                var tot = g.Count();
                var cor = g.Count(x => x.IsCorrect);
                return new SubjectSummaryDto
                {
                    SubjectName = g.Key,
                    TotalQuestions = tot,
                    CorrectAnswers = cor,
                    WrongAnswers = tot - cor,
                    CorrectAnswerRate = tot > 0 ? Math.Round((decimal)cor / tot, 2) : 0,
                };
            })
            .OrderBy(s => s.SubjectName)
            .ToList();

        return new DailySummaryDto
        {
            ChildId = childId,
            Date = dayStart,
            TotalQuestionsAnswered = total,
            CorrectAnswers = correct,
            WrongAnswers = wrong,
            CorrectAnswerRate = total > 0 ? Math.Round((decimal)correct / total, 2) : 0,
            LevelsCompleted = levelResults.Count,
            PointsEarned = levelResults.Sum(lr => lr.Score) + matchPoints,
            StarsEarned = levelResults.Sum(lr => lr.Stars),
            SubjectBreakdown = subjectBreakdown,
        };
    }

    public async Task<WeeklySummaryDto> GetWeeklySummaryAsync(Guid childId, DateTime weekStart)
    {
        var start = weekStart.Date;
        var end = start.AddDays(7);

        var dailyBreakdown = new List<DailySummaryDto>();
        for (var d = start; d < end; d = d.AddDays(1))
        {
            dailyBreakdown.Add(await GetDailySummaryAsync(childId, d));
        }

        var activeDays = dailyBreakdown.Count(d => d.TotalQuestionsAnswered > 0);
        var totalCorrect = dailyBreakdown.Sum(d => d.CorrectAnswers);
        var totalQuestions = dailyBreakdown.Sum(d => d.TotalQuestionsAnswered);

        // Haftalık ders bazlı breakdown (günlük breakdown'lardan aggregate)
        var weeklySubjectBreakdown = dailyBreakdown
            .SelectMany(d => d.SubjectBreakdown)
            .GroupBy(s => s.SubjectName)
            .Select(g =>
            {
                var tot = g.Sum(s => s.TotalQuestions);
                var cor = g.Sum(s => s.CorrectAnswers);
                return new SubjectSummaryDto
                {
                    SubjectName = g.Key,
                    TotalQuestions = tot,
                    CorrectAnswers = cor,
                    WrongAnswers = tot - cor,
                    CorrectAnswerRate = tot > 0 ? Math.Round((decimal)cor / tot, 2) : 0,
                };
            })
            .OrderBy(s => s.SubjectName)
            .ToList();

        return new WeeklySummaryDto
        {
            ChildId = childId,
            WeekStart = start,
            WeekEnd = end.AddSeconds(-1),
            TotalQuestionsAnswered = totalQuestions,
            CorrectAnswers = totalCorrect,
            WrongAnswers = dailyBreakdown.Sum(d => d.WrongAnswers),
            CorrectAnswerRate = totalQuestions > 0 ? Math.Round((decimal)totalCorrect / totalQuestions, 2) : 0,
            LevelsCompleted = dailyBreakdown.Sum(d => d.LevelsCompleted),
            TotalPointsEarned = dailyBreakdown.Sum(d => d.PointsEarned),
            TotalStarsEarned = dailyBreakdown.Sum(d => d.StarsEarned),
            ActiveDays = activeDays,
            DailyBreakdown = dailyBreakdown,
            SubjectBreakdown = weeklySubjectBreakdown,
        };
    }

    public async Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId, int topN = 5)
    {
        var attempts = await _progressRepository.GetAnswerAttemptsWithTopicAsync(childId);
        var matchAnswers = await _progressRepository.GetMatchAnswersWithTopicAsync(childId);

        // Solo denemeleri ortak forma dönüştür
        var soloItems = attempts
            .Where(a => a.Question?.Level?.Topic != null)
            .Select(a => (Topic: a.Question.Level.Topic, IsCorrect: a.IsCorrect));

        // Maç cevaplarını ortak forma dönüştür
        var matchItems = matchAnswers
            .Where(a => a.Question?.Level?.Topic != null)
            .Select(a => (Topic: a.Question.Level.Topic, IsCorrect: a.IsCorrect));

        var grouped = soloItems.Concat(matchItems)
            .GroupBy(x => x.Topic)
            .Select(g => new WeakTopicDto
            {
                TopicId = g.Key.Id,
                TopicName = g.Key.Name,
                SubjectName = g.Key.Subject?.Name ?? string.Empty,
                TotalAttempts = g.Count(),
                CorrectAttempts = g.Count(x => x.IsCorrect),
                SuccessRate = g.Count() > 0
                    ? Math.Round((decimal)g.Count(x => x.IsCorrect) / g.Count(), 2)
                    : 0,
            })
            .Where(t => t.TotalAttempts >= 3)
            .OrderBy(t => t.SuccessRate)
            .Take(topN)
            .ToList();

        return grouped;
    }
}
