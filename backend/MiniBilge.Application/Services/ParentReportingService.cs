using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Options;

namespace MiniBilge.Application.Services;

public class ParentReportingService : IParentReportingService
{
    private readonly IProgressRepository _progressRepository;
    private readonly IPodcastRepository   _podcastRepository;
    private readonly IChallengeRepository _challengeRepository;
    private readonly IClassroomRepository _classroomRepository;
    private readonly IGameStatsRepository _gameStatsRepository;

    public ParentReportingService(
        IProgressRepository progressRepository,
        IPodcastRepository   podcastRepository,
        IChallengeRepository challengeRepository,
        IClassroomRepository classroomRepository,
        IGameStatsRepository gameStatsRepository)
    {
        _progressRepository  = progressRepository;
        _podcastRepository   = podcastRepository;
        _challengeRepository = challengeRepository;
        _classroomRepository = classroomRepository;
        _gameStatsRepository = gameStatsRepository;
    }

    public async Task<DailySummaryDto> GetDailySummaryAsync(Guid childId, DateTime date)
    {
        var dayStart = date.Date;
        var dayEnd = dayStart.AddDays(1);

        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, dayStart, dayEnd);
        var matchAnswers = await _progressRepository.GetMatchAnswersByDateRangeAsync(childId, dayStart, dayEnd);
        var levelResults = await _progressRepository.GetLevelResultsByDateRangeAsync(childId, dayStart, dayEnd);
        var entertainment = await _progressRepository.GetEntertainmentActivitiesByDateRangeAsync(childId, dayStart, dayEnd);
        var vocab = await _progressRepository.GetEnglishVocabActivitiesByDateRangeAsync(childId, dayStart, dayEnd);

        // Solo + maç + eğlence quizi + kelime oyunu cevaplarını birleştir. Eğlence quizi ve
        // kelime oyununun dersi/konusu yoktur; yalnızca üst toplamlara (soru/doğru/yanlış) katkı verir.
        var entertainmentQuestions = entertainment.Sum(e => e.QuestionCount) + vocab.Sum(e => e.QuestionCount);
        var entertainmentCorrect = entertainment.Sum(e => e.CorrectCount) + vocab.Sum(e => e.CorrectCount);
        var correct = attempts.Count(a => a.IsCorrect) + matchAnswers.Count(a => a.IsCorrect) + entertainmentCorrect;
        var wrong = attempts.Count(a => !a.IsCorrect) + matchAnswers.Count(a => !a.IsCorrect)
                    + (entertainmentQuestions - entertainmentCorrect);
        var total = attempts.Count + matchAnswers.Count + entertainmentQuestions;

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

    public async Task<ActivitySummaryDto> GetActivitySummaryAsync(Guid childId)
    {
        // EF Core DbContext is not thread-safe — run sequentially (no Task.WhenAll)
        var podcastCount  = await _podcastRepository.GetCompletedQuizCountAsync(childId);
        var (total, won, lost) = await _challengeRepository.GetStatsAsync(childId);
        var assignmentCount = await _classroomRepository.GetCompletedAssignmentsCountAsync(childId);

        return new ActivitySummaryDto
        {
            ChildId              = childId,
            PodcastsCompleted    = podcastCount,
            ChallengesTotal      = total,
            ChallengesWon        = won,
            ChallengesLost       = lost,
            AssignmentsCompleted = assignmentCount,
        };
    }

    public async Task<ProgressTrendDto> GetProgressTrendAsync(Guid childId, int days)
    {
        // Bugün dahil son `days` takvim günü.
        var now = DateTime.UtcNow.Date;
        var rangeStart = now.AddDays(-(days - 1));
        var rangeEnd = now.AddDays(1); // exclusive

        // Tüm pencereyi tek seferde çek (gün başına sorgu yerine).
        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, rangeStart, rangeEnd);
        var matchAnswers = await _progressRepository.GetMatchAnswersByDateRangeAsync(childId, rangeStart, rangeEnd);
        var levelResults = await _progressRepository.GetLevelResultsByDateRangeAsync(childId, rangeStart, rangeEnd);

        var weeklyTrend = new List<TrendPointDto>();
        for (var ws = rangeStart; ws < rangeEnd; ws = ws.AddDays(7))
        {
            var we = ws.AddDays(7);
            if (we > rangeEnd) we = rangeEnd;

            var weekAttempts = attempts.Where(a => a.AttemptedAt >= ws && a.AttemptedAt < we).ToList();
            var weekMatches = matchAnswers.Where(a => a.AnsweredAt >= ws && a.AnsweredAt < we).ToList();

            var weekTotal = weekAttempts.Count + weekMatches.Count;
            var weekCorrect = weekAttempts.Count(a => a.IsCorrect) + weekMatches.Count(a => a.IsCorrect);
            var weekActiveDays = weekAttempts.Select(a => a.AttemptedAt.Date)
                .Concat(weekMatches.Select(a => a.AnsweredAt.Date))
                .Distinct().Count();

            weeklyTrend.Add(new TrendPointDto
            {
                WeekStart = ws,
                WeekEnd = we.AddSeconds(-1),
                TotalQuestionsAnswered = weekTotal,
                CorrectAnswers = weekCorrect,
                CorrectAnswerRate = weekTotal > 0 ? Math.Round((decimal)weekCorrect / weekTotal, 2) : 0,
                ActiveDays = weekActiveDays,
            });
        }

        var total = attempts.Count + matchAnswers.Count;
        var correct = attempts.Count(a => a.IsCorrect) + matchAnswers.Count(a => a.IsCorrect);
        var activeDays = attempts.Select(a => a.AttemptedAt.Date)
            .Concat(matchAnswers.Select(a => a.AnsweredAt.Date))
            .Distinct().Count();

        return new ProgressTrendDto
        {
            ChildId = childId,
            Days = days,
            PeriodStart = rangeStart,
            PeriodEnd = rangeEnd.AddSeconds(-1),
            TotalQuestionsAnswered = total,
            CorrectAnswers = correct,
            CorrectAnswerRate = total > 0 ? Math.Round((decimal)correct / total, 2) : 0,
            ActiveDays = activeDays,
            LevelsCompleted = levelResults.Count,
            TotalPointsEarned = levelResults.Sum(lr => lr.Score) + matchAnswers.Sum(a => a.PointsEarned),
            TotalStarsEarned = levelResults.Sum(lr => lr.Stars),
            WeeklyTrend = weeklyTrend,
        };
    }

    public async Task<List<TopicPerformanceDto>> GetTopicPerformanceAsync(Guid childId, int days)
    {
        var now = DateTime.UtcNow.Date;
        var rangeStart = now.AddDays(-(days - 1));
        var rangeEnd = now.AddDays(1); // exclusive

        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, rangeStart, rangeEnd);
        var matchAnswers = await _progressRepository.GetMatchAnswersByDateRangeAsync(childId, rangeStart, rangeEnd);

        // Solo (süre bilgili) + maç cevaplarını ortak forma indir.
        var soloItems = attempts
            .Where(a => a.Question?.Level?.Topic != null)
            .Select(a => (Topic: a.Question.Level.Topic, a.IsCorrect,
                TimeSeconds: a.TimeTakenSeconds, Date: a.AttemptedAt.Date));

        var matchItems = matchAnswers
            .Where(a => a.Question?.Level?.Topic != null)
            .Select(a => (Topic: a.Question.Level.Topic, a.IsCorrect,
                TimeSeconds: (int?)null, Date: a.AnsweredAt.Date));

        return soloItems.Concat(matchItems)
            .GroupBy(x => x.Topic)
            .Select(g =>
            {
                var totalAttempts = g.Count();
                var correctAttempts = g.Count(x => x.IsCorrect);
                var timed = g.Where(x => x.TimeSeconds.HasValue).Select(x => x.TimeSeconds!.Value).ToList();
                return new TopicPerformanceDto
                {
                    TopicId = g.Key.Id,
                    TopicName = g.Key.Name,
                    SubjectName = g.Key.Subject?.Name ?? string.Empty,
                    TotalAttempts = totalAttempts,
                    CorrectAttempts = correctAttempts,
                    SuccessRate = totalAttempts > 0
                        ? Math.Round((decimal)correctAttempts / totalAttempts, 2)
                        : 0,
                    AverageTimeSeconds = timed.Count > 0 ? Math.Round(timed.Average(), 1) : null,
                    DistinctDaysPracticed = g.Select(x => x.Date).Distinct().Count(),
                    LastPracticedAt = g.Max(x => x.Date),
                };
            })
            .OrderBy(t => t.SuccessRate)
            .ThenByDescending(t => t.TotalAttempts)
            .ToList();
    }

    public async Task<List<RecommendationDto>> GetWeeklyRecommendationsAsync(Guid childId)
    {
        var trend = await GetProgressTrendAsync(childId, 7);
        var weakTopics = await GetWeakTopicsAsync(childId, topN: 2);

        var recs = new List<RecommendationDto>();

        // 1) Zayıf konu(lar).
        foreach (var wt in weakTopics)
        {
            var percent = (int)Math.Round(wt.SuccessRate * 100);
            recs.Add(new RecommendationDto
            {
                Key = "weak_topic",
                Priority = 1,
                TopicId = wt.TopicId,
                Title = $"{wt.TopicName} konusunu güçlendirin",
                Message = $"{wt.SubjectName} / {wt.TopicName} başarısı %{percent}. Bu hafta bu konuya odaklanmak faydalı olur.",
            });
        }

        // 2) Düzenlilik.
        if (trend.ActiveDays < 3)
        {
            recs.Add(new RecommendationDto
            {
                Key = "consistency",
                Priority = trend.ActiveDays == 0 ? 1 : 2,
                Title = "Düzenli çalışma alışkanlığı",
                Message = trend.ActiveDays == 0
                    ? "Bu hafta henüz çalışma yok. Kısa günlük seanslar öğrenmeyi kalıcı kılar."
                    : $"Bu hafta {trend.ActiveDays} gün çalışıldı. Haftada en az 3-4 gün hedeflemek gelişimi hızlandırır.",
            });
        }

        // 3) Doğruluk düşükse.
        if (trend.TotalQuestionsAnswered >= 10 && trend.CorrectAnswerRate < 0.5m)
        {
            var percent = (int)Math.Round(trend.CorrectAnswerRate * 100);
            recs.Add(new RecommendationDto
            {
                Key = "accuracy",
                Priority = 2,
                Title = "Daha kolay seviyeden pekiştirme",
                Message = $"Bu haftaki doğruluk %{percent}. Temel seviyeden tekrar özgüveni artırır.",
            });
        }

        // 4) Her şey iyiyse olumlu geri bildirim.
        if (recs.Count == 0)
        {
            recs.Add(new RecommendationDto
            {
                Key = "positive",
                Priority = 3,
                Title = "Harika gidiyor!",
                Message = "Bu hafta düzenli ve başarılı bir çalışma var. Aynı tempoyu koruyun.",
            });
        }

        return recs.OrderBy(r => r.Priority).ToList();
    }

    public async Task<FamilySummaryDto> GetFamilySummaryAsync(
        IReadOnlyList<(Guid ChildId, string ChildName)> children, int days)
    {
        var now = DateTime.UtcNow.Date;
        var childSummaries = new List<FamilyChildSummaryDto>();

        // EF Core DbContext thread-safe değil — çocukları sırayla işle.
        foreach (var (childId, name) in children)
        {
            var trend = await GetProgressTrendAsync(childId, days);
            childSummaries.Add(new FamilyChildSummaryDto
            {
                ChildId = childId,
                ChildName = name,
                TotalQuestionsAnswered = trend.TotalQuestionsAnswered,
                CorrectAnswers = trend.CorrectAnswers,
                CorrectAnswerRate = trend.CorrectAnswerRate,
                ActiveDays = trend.ActiveDays,
                LevelsCompleted = trend.LevelsCompleted,
                TotalStarsEarned = trend.TotalStarsEarned,
            });
        }

        var totalQuestions = childSummaries.Sum(c => c.TotalQuestionsAnswered);
        var totalCorrect = childSummaries.Sum(c => c.CorrectAnswers);

        return new FamilySummaryDto
        {
            Days = days,
            PeriodStart = now.AddDays(-(days - 1)),
            PeriodEnd = now,
            TotalChildren = childSummaries.Count,
            TotalQuestionsAnswered = totalQuestions,
            CorrectAnswers = totalCorrect,
            CorrectAnswerRate = totalQuestions > 0
                ? Math.Round((decimal)totalCorrect / totalQuestions, 2)
                : 0,
            Children = childSummaries
                .OrderByDescending(c => c.TotalQuestionsAnswered)
                .ToList(),
        };
    }

    public async Task<EntertainmentStatsDto> GetEntertainmentStatsAsync(Guid childId)
    {
        var rows = await _gameStatsRepository.GetStatsForGameTypeAsync(childId, "fun");

        var aggregate = rows.FirstOrDefault(r => r.CategoryKey == string.Empty);
        var categories = rows
            .Where(r => r.CategoryKey != string.Empty && r.Played > 0)
            .Select(r => new EntertainmentCategoryStatDto
            {
                CategoryKey = r.CategoryKey,
                CategoryName = EntertainmentTopics.All.TryGetValue(r.CategoryKey, out var cfg)
                    ? cfg.Label
                    : r.CategoryKey,
                Played = r.Played,
                Won = r.Won,
                AverageSuccessRate = r.Played > 0
                    ? Math.Round((decimal)r.SuccessPercentageSum / r.Played, 1)
                    : 0,
            })
            .OrderByDescending(c => c.Played)
            .ToList();

        return new EntertainmentStatsDto
        {
            ChildId = childId,
            TotalPlayed = aggregate?.Played ?? 0,
            TotalWon = aggregate?.Won ?? 0,
            PerfectWins = aggregate?.PerfectWins ?? 0,
            AverageSuccessRate = aggregate is { Played: > 0 }
                ? Math.Round((decimal)aggregate.SuccessPercentageSum / aggregate.Played, 1)
                : 0,
            Categories = categories,
        };
    }

    public async Task<ChallengeHistoryDto> GetChallengeHistoryAsync(Guid childId)
    {
        // Son 3 ay: veri biriktikçe performans/karmaşıklık kontrolü için pencere sabit.
        var since = DateTime.UtcNow.AddDays(-90);
        var challenges = await _challengeRepository.GetCompletedSinceAsync(childId, since);

        var buckets = new Dictionary<string, ChallengeCategoryStatDto>();
        int won = 0, lost = 0, tie = 0;

        foreach (var c in challenges)
        {
            var childIsChallenger = c.ChallengerId == childId;
            var myScore = childIsChallenger ? c.ChallengerScore!.Value : c.ChallengeeScore!.Value;
            var oppScore = childIsChallenger ? c.ChallengeeScore!.Value : c.ChallengerScore!.Value;

            var category = ResolveChallengeCategory(c);

            if (!buckets.TryGetValue(category, out var bucket))
            {
                bucket = new ChallengeCategoryStatDto { Category = category };
                buckets[category] = bucket;
            }

            bucket.Played++;
            if (myScore > oppScore) { bucket.Won++; won++; }
            else if (myScore < oppScore) { bucket.Lost++; lost++; }
            else { bucket.Tie++; tie++; }
        }

        var categories = buckets.Values
            .Select(b =>
            {
                b.WinRate = b.Played > 0
                    ? Math.Round((decimal)b.Won / b.Played * 100, 1)
                    : 0;
                return b;
            })
            .OrderByDescending(b => b.Played)
            .ToList();

        return new ChallengeHistoryDto
        {
            ChildId = childId,
            TotalCompleted = won + lost + tie,
            Won = won,
            Lost = lost,
            Tie = tie,
            Categories = categories,
        };
    }

    // İngilizce/Matematik tek satırda toplanır; yalnızca eğlence yarışmaları kategoriye ayrılır.
    private static string ResolveChallengeCategory(Domain.Entities.Challenge c)
    {
        // Eğitim (ders temelli) meydan okuması: ders adına indirger (alt konu/sınıf kırılımı yok).
        var subject = c.Level?.Topic?.Subject?.Name;
        if (!string.IsNullOrWhiteSpace(subject))
            return subject;

        // Yetişkin İngilizce yarışması: odak alt konusundan bağımsız tek satır.
        if (c.CompetitionType == Domain.Enums.AdultCompetitionType.EnglishQuiz)
            return "İngilizce";

        // Eğlence yarışmaları: kategori bazlı (ör. Genel Kültür, Spor, Teknoloji).
        var baseKey = c.CompetitionTopicKey?.Split(':', 2)[0];
        if (!string.IsNullOrWhiteSpace(baseKey))
        {
            if (baseKey == "ingilizce") return "İngilizce";
            if (EntertainmentTopics.All.TryGetValue(baseKey, out var cfg))
                return cfg.Label;
            return baseKey;
        }

        return "Yarışma";
    }
}
