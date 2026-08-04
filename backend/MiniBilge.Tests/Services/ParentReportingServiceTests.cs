using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class ParentReportingServiceTests
{
    private readonly Mock<IProgressRepository>   _mockProgressRepository;
    private readonly Mock<IPodcastRepository>    _mockPodcastRepository;
    private readonly Mock<IChallengeRepository>  _mockChallengeRepository;
    private readonly Mock<IClassroomRepository>  _mockClassroomRepository;
    private readonly Mock<IGameStatsRepository>  _mockGameStatsRepository;
    private readonly ParentReportingService _service;

    private static readonly Guid ChildId = Guid.NewGuid();
    private static readonly DateTime Today = new DateTime(2026, 4, 23, 0, 0, 0, DateTimeKind.Utc);

    public ParentReportingServiceTests()
    {
        _mockProgressRepository  = new Mock<IProgressRepository>();
        _mockPodcastRepository   = new Mock<IPodcastRepository>();
        _mockChallengeRepository = new Mock<IChallengeRepository>();
        _mockClassroomRepository = new Mock<IClassroomRepository>();
        _mockGameStatsRepository = new Mock<IGameStatsRepository>();

        _service = new ParentReportingService(
            _mockProgressRepository.Object,
            _mockPodcastRepository.Object,
            _mockChallengeRepository.Object,
            _mockClassroomRepository.Object,
            _mockGameStatsRepository.Object);

        // Yeni metotlar için varsayılan boş döndür (testler override edebilir)
        _mockProgressRepository
            .Setup(r => r.GetMatchAnswersByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<MatchAnswer>());
        _mockProgressRepository
            .Setup(r => r.GetMatchAnswersWithTopicAsync(It.IsAny<Guid>()))
            .ReturnsAsync(new List<MatchAnswer>());
        _mockProgressRepository
            .Setup(r => r.GetEntertainmentActivitiesByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<EntertainmentActivity>());
    }

    #region GetDailySummary Tests

    [Fact]
    public async Task GetDailySummary_WithNoAttempts_ShouldReturnZeroStats()
    {
        // Arrange
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(new List<AnswerAttempt>());

        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(new List<LevelResult>());

        // Act
        var result = await _service.GetDailySummaryAsync(ChildId, Today);

        // Assert
        result.Should().NotBeNull();
        result.TotalQuestionsAnswered.Should().Be(0);
        result.CorrectAnswers.Should().Be(0);
        result.WrongAnswers.Should().Be(0);
        result.CorrectAnswerRate.Should().Be(0);
        result.LevelsCompleted.Should().Be(0);
        result.PointsEarned.Should().Be(0);
    }

    [Fact]
    public async Task GetDailySummary_WithMixedAttempts_ShouldCalculateCorrectly()
    {
        // Arrange
        var attempts = new List<AnswerAttempt>
        {
            new() { ChildId = ChildId, IsCorrect = true,  AttemptedAt = Today.AddHours(9) },
            new() { ChildId = ChildId, IsCorrect = true,  AttemptedAt = Today.AddHours(9) },
            new() { ChildId = ChildId, IsCorrect = true,  AttemptedAt = Today.AddHours(9) },
            new() { ChildId = ChildId, IsCorrect = false, AttemptedAt = Today.AddHours(9) },
            new() { ChildId = ChildId, IsCorrect = false, AttemptedAt = Today.AddHours(9) },
        };

        var levelResults = new List<LevelResult>
        {
            new() { ChildId = ChildId, Score = 30, Stars = 2, CompletedAt = Today.AddHours(9) },
        };

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(attempts);

        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(levelResults);

        // Act
        var result = await _service.GetDailySummaryAsync(ChildId, Today);

        // Assert
        result.TotalQuestionsAnswered.Should().Be(5);
        result.CorrectAnswers.Should().Be(3);
        result.WrongAnswers.Should().Be(2);
        result.CorrectAnswerRate.Should().Be(0.60m); // 3/5
        result.LevelsCompleted.Should().Be(1);
        result.PointsEarned.Should().Be(30);
        result.StarsEarned.Should().Be(2);
    }

    [Fact]
    public async Task GetDailySummary_WithAllCorrect_ShouldReturnFullRate()
    {
        // Arrange
        var attempts = Enumerable.Range(0, 10)
            .Select(_ => new AnswerAttempt { ChildId = ChildId, IsCorrect = true, AttemptedAt = Today })
            .ToList();

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(attempts);

        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(ChildId, Today, Today.AddDays(1)))
            .ReturnsAsync(new List<LevelResult>());

        // Act
        var result = await _service.GetDailySummaryAsync(ChildId, Today);

        // Assert
        result.CorrectAnswerRate.Should().Be(1.00m);
        result.CorrectAnswers.Should().Be(10);
        result.WrongAnswers.Should().Be(0);
    }

    #endregion

    #region GetWeeklySummary Tests

    [Fact]
    public async Task GetWeeklySummary_ShouldAggregate7Days()
    {
        // Arrange — her gün 2 doğru 1 yanlış cevap
        var weekStart = Today.AddDays(-(int)Today.DayOfWeek + 1); // Pazartesi
        for (int i = 0; i < 7; i++)
        {
            var day = weekStart.AddDays(i);
            _mockProgressRepository
                .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(ChildId, day, day.AddDays(1)))
                .ReturnsAsync(new List<AnswerAttempt>
                {
                    new() { IsCorrect = true,  AttemptedAt = day },
                    new() { IsCorrect = true,  AttemptedAt = day },
                    new() { IsCorrect = false, AttemptedAt = day },
                });

            _mockProgressRepository
                .Setup(r => r.GetLevelResultsByDateRangeAsync(ChildId, day, day.AddDays(1)))
                .ReturnsAsync(new List<LevelResult>
                {
                    new() { Score = 20, Stars = 1, CompletedAt = day },
                });
        }

        // Act
        var result = await _service.GetWeeklySummaryAsync(ChildId, weekStart);

        // Assert
        result.TotalQuestionsAnswered.Should().Be(21); // 7 * 3
        result.CorrectAnswers.Should().Be(14);         // 7 * 2
        result.WrongAnswers.Should().Be(7);            // 7 * 1
        result.ActiveDays.Should().Be(7);
        result.LevelsCompleted.Should().Be(7);
        result.TotalPointsEarned.Should().Be(140);     // 7 * 20
        result.TotalStarsEarned.Should().Be(7);
        result.DailyBreakdown.Should().HaveCount(7);
    }

    [Fact]
    public async Task GetWeeklySummary_WithInactiveDays_ShouldCountActiveDaysCorrectly()
    {
        // Arrange — sadece 3 gün aktif
        var weekStart = Today;
        for (int i = 0; i < 7; i++)
        {
            var day = weekStart.AddDays(i);
            var hasActivity = i < 3; // Sadece ilk 3 gün

            _mockProgressRepository
                .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(ChildId, day, day.AddDays(1)))
                .ReturnsAsync(hasActivity
                    ? new List<AnswerAttempt> { new() { IsCorrect = true, AttemptedAt = day } }
                    : new List<AnswerAttempt>());

            _mockProgressRepository
                .Setup(r => r.GetLevelResultsByDateRangeAsync(ChildId, day, day.AddDays(1)))
                .ReturnsAsync(new List<LevelResult>());
        }

        // Act
        var result = await _service.GetWeeklySummaryAsync(ChildId, weekStart);

        // Assert
        result.ActiveDays.Should().Be(3);
        result.TotalQuestionsAnswered.Should().Be(3);
    }

    #endregion

    #region GetWeakTopics Tests

    [Fact]
    public async Task GetWeakTopics_WithNoAttempts_ShouldReturnEmpty()
    {
        // Arrange
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(new List<AnswerAttempt>());

        // Act
        var result = await _service.GetWeakTopicsAsync(ChildId);

        // Assert
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetWeakTopics_ShouldReturnTopicsOrderedBySuccessRateAscending()
    {
        // Arrange
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };

        var topicA = new Topic { Id = Guid.NewGuid(), Name = "Toplama",   Subject = subject };
        var topicB = new Topic { Id = Guid.NewGuid(), Name = "Çıkarma",   Subject = subject };
        var topicC = new Topic { Id = Guid.NewGuid(), Name = "Çarpma",    Subject = subject };

        var levelA = new Level { Topic = topicA };
        var levelB = new Level { Topic = topicB };
        var levelC = new Level { Topic = topicC };

        var qA = new Question { Level = levelA };
        var qB = new Question { Level = levelB };
        var qC = new Question { Level = levelC };

        // topicA: 1/5 = 0.20 (zayıf)
        // topicB: 4/5 = 0.80 (iyi)
        // topicC: 3/5 = 0.60 (orta)
        var attempts = new List<AnswerAttempt>();
        for (int i = 0; i < 5; i++) attempts.Add(new() { Question = qA, IsCorrect = i == 0 });
        for (int i = 0; i < 5; i++) attempts.Add(new() { Question = qB, IsCorrect = i < 4 });
        for (int i = 0; i < 5; i++) attempts.Add(new() { Question = qC, IsCorrect = i < 3 });

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(attempts);

        // Act
        var result = await _service.GetWeakTopicsAsync(ChildId, topN: 5);

        // Assert
        result.Should().HaveCount(3);
        result[0].TopicName.Should().Be("Toplama"); // En zayıf önce
        result[0].SuccessRate.Should().Be(0.20m);
        result[1].TopicName.Should().Be("Çarpma");
        result[2].TopicName.Should().Be("Çıkarma");
    }

    [Fact]
    public async Task GetWeakTopics_WithTopicHavingFewerThan3Attempts_ShouldExclude()
    {
        // Arrange
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };
        var topic  = new Topic { Id = Guid.NewGuid(), Name = "Kesirler", Subject = subject };
        var level  = new Level { Topic = topic };
        var q      = new Question { Level = level };

        // Sadece 2 deneme — eşik altında
        var attempts = new List<AnswerAttempt>
        {
            new() { Question = q, IsCorrect = false },
            new() { Question = q, IsCorrect = false },
        };

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(attempts);

        // Act
        var result = await _service.GetWeakTopicsAsync(ChildId);

        // Assert
        result.Should().BeEmpty();
    }

    [Fact]
    public async Task GetWeakTopics_ShouldRespectTopNLimit()
    {
        // Arrange
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };

        var attempts = new List<AnswerAttempt>();
        for (int t = 0; t < 6; t++)
        {
            var topic = new Topic { Id = Guid.NewGuid(), Name = $"Konu{t}", Subject = subject };
            var level = new Level { Topic = topic };
            var q     = new Question { Level = level };
            for (int i = 0; i < 5; i++)
                attempts.Add(new() { Question = q, IsCorrect = false });
        }

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(attempts);

        // Act
        var result = await _service.GetWeakTopicsAsync(ChildId, topN: 3);

        // Assert
        result.Should().HaveCount(3);
    }

    #endregion

    #region GetProgressTrend Tests (P6-B05)

    [Fact]
    public async Task GetProgressTrend_WithNoData_ShouldReturnZeroTotals()
    {
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>());
        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<LevelResult>());

        var result = await _service.GetProgressTrendAsync(ChildId, 30);

        result.Days.Should().Be(30);
        result.TotalQuestionsAnswered.Should().Be(0);
        result.CorrectAnswerRate.Should().Be(0);
        result.ActiveDays.Should().Be(0);
        // 30 gün = 5 haftalık kova (30/7 yukarı yuvarlanır).
        result.WeeklyTrend.Should().HaveCount(5);
    }

    [Fact]
    public async Task GetProgressTrend_ShouldAggregateTotalsAndActiveDays()
    {
        var now = DateTime.UtcNow.Date;
        var attempts = new List<AnswerAttempt>
        {
            new() { IsCorrect = true,  AttemptedAt = now },
            new() { IsCorrect = false, AttemptedAt = now },
            new() { IsCorrect = true,  AttemptedAt = now.AddDays(-1) },
            new() { IsCorrect = true,  AttemptedAt = now.AddDays(-10) },
        };
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(attempts);
        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<LevelResult>
            {
                new() { Score = 100, Stars = 2, CompletedAt = now },
            });

        var result = await _service.GetProgressTrendAsync(ChildId, 30);

        result.TotalQuestionsAnswered.Should().Be(4);
        result.CorrectAnswers.Should().Be(3);
        result.CorrectAnswerRate.Should().Be(0.75m);
        result.ActiveDays.Should().Be(3); // now, now-1, now-10 → 3 farklı gün
        result.LevelsCompleted.Should().Be(1);
        result.TotalPointsEarned.Should().Be(100);
        result.TotalStarsEarned.Should().Be(2);
    }

    #endregion

    #region GetTopicPerformance Tests (P6-B06)

    [Fact]
    public async Task GetTopicPerformance_ShouldComputeMetricsAndOrderWeakestFirst()
    {
        var now = DateTime.UtcNow.Date;
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };
        var weakTopic = new Topic { Id = Guid.NewGuid(), Name = "Kesirler", Subject = subject };
        var strongTopic = new Topic { Id = Guid.NewGuid(), Name = "Toplama", Subject = subject };
        var qWeak = new Question { Level = new Level { Topic = weakTopic } };
        var qStrong = new Question { Level = new Level { Topic = strongTopic } };

        var attempts = new List<AnswerAttempt>
        {
            // Kesirler: 1/3 doğru, süreler 10 ve 20 → ort 15, 2 farklı gün
            new() { Question = qWeak, IsCorrect = true,  TimeTakenSeconds = 10, AttemptedAt = now },
            new() { Question = qWeak, IsCorrect = false, TimeTakenSeconds = 20, AttemptedAt = now.AddDays(-1) },
            new() { Question = qWeak, IsCorrect = false, TimeTakenSeconds = null, AttemptedAt = now.AddDays(-1) },
            // Toplama: 3/3 doğru
            new() { Question = qStrong, IsCorrect = true, TimeTakenSeconds = 5, AttemptedAt = now },
            new() { Question = qStrong, IsCorrect = true, TimeTakenSeconds = 5, AttemptedAt = now },
            new() { Question = qStrong, IsCorrect = true, TimeTakenSeconds = 5, AttemptedAt = now },
        };
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(attempts);

        var result = await _service.GetTopicPerformanceAsync(ChildId, 30);

        result.Should().HaveCount(2);
        result[0].TopicName.Should().Be("Kesirler"); // en zayıf önce
        result[0].SuccessRate.Should().Be(0.33m);
        result[0].AverageTimeSeconds.Should().Be(15.0);
        result[0].DistinctDaysPracticed.Should().Be(2);
        result[1].TopicName.Should().Be("Toplama");
        result[1].SuccessRate.Should().Be(1.00m);
    }

    #endregion

    #region GetWeeklyRecommendations Tests (P6-B08)

    [Fact]
    public async Task GetWeeklyRecommendations_WithNoActivity_ShouldRecommendConsistency()
    {
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>());
        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<LevelResult>());
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(new List<AnswerAttempt>());

        var result = await _service.GetWeeklyRecommendationsAsync(ChildId);

        result.Should().Contain(r => r.Key == "consistency");
    }

    [Fact]
    public async Task GetWeeklyRecommendations_WithWeakTopic_ShouldRecommendItFirst()
    {
        var now = DateTime.UtcNow.Date;
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };
        var topic = new Topic { Id = Guid.NewGuid(), Name = "Kesirler", Subject = subject };
        var q = new Question { Level = new Level { Topic = topic } };

        var weakAttempts = new List<AnswerAttempt>();
        for (int i = 0; i < 5; i++)
            weakAttempts.Add(new() { Question = q, IsCorrect = false });

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsWithTopicAsync(ChildId))
            .ReturnsAsync(weakAttempts);
        // 7 günlük pencerede aktif çalışma → düzenlilik önerisi çıkmasın diye 3+ gün.
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>
            {
                new() { Question = q, IsCorrect = true, AttemptedAt = now },
                new() { Question = q, IsCorrect = true, AttemptedAt = now.AddDays(-1) },
                new() { Question = q, IsCorrect = true, AttemptedAt = now.AddDays(-2) },
            });
        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<LevelResult>());

        var result = await _service.GetWeeklyRecommendationsAsync(ChildId);

        result[0].Key.Should().Be("weak_topic");
        result[0].TopicId.Should().Be(topic.Id);
    }

    #endregion

    #region GetFamilySummary Tests (P6-B07)

    [Fact]
    public async Task GetFamilySummary_ShouldAggregateAcrossChildren()
    {
        var now = DateTime.UtcNow.Date;
        var childA = Guid.NewGuid();
        var childB = Guid.NewGuid();

        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(childA, It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>
            {
                new() { IsCorrect = true, AttemptedAt = now },
                new() { IsCorrect = false, AttemptedAt = now },
            });
        _mockProgressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(childB, It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>
            {
                new() { IsCorrect = true, AttemptedAt = now },
            });
        _mockProgressRepository
            .Setup(r => r.GetLevelResultsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<LevelResult>());

        var children = new List<(Guid, string)> { (childA, "Ali"), (childB, "Ayşe") };
        var result = await _service.GetFamilySummaryAsync(children, 7);

        result.TotalChildren.Should().Be(2);
        result.TotalQuestionsAnswered.Should().Be(3);
        result.CorrectAnswers.Should().Be(2);
        result.Children.Should().HaveCount(2);
        result.Children[0].ChildName.Should().Be("Ali"); // daha çok soru → önce
    }

    #endregion
}
