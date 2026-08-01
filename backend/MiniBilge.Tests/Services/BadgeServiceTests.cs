using FluentAssertions;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class BadgeServiceTests
{
    private static (BadgeService service, Mock<IBadgeRepository> repo) CreateService(
        Func<Guid, string, bool>? hasEarned = null)
    {
        var repo = new Mock<IBadgeRepository>();

        // Her key için geçerli bir rozet döndür (katalogda hepsi var kabul edilir)
        repo.Setup(r => r.GetByKeyAsync(It.IsAny<string>()))
            .ReturnsAsync((string key) => new Badge { Id = Guid.NewGuid(), Key = key, IsActive = true });

        repo.Setup(r => r.HasEarnedAsync(It.IsAny<Guid>(), It.IsAny<string>()))
            .ReturnsAsync((Guid childId, string key) => hasEarned?.Invoke(childId, key) ?? false);

        var logger = new Mock<ILogger<BadgeService>>();
        return (new BadgeService(repo.Object, logger.Object), repo);
    }

    // ── Quiz tamamlama rozetleri ────────────────────────────────────────

    [Fact]
    public async Task QuizCompleted_EligibleNewQuiz_AwardsFirstQuiz()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { IsEligibleNewQuiz = true });

        result.Should().Contain("first_quiz");
    }

    [Theory]
    [InlineData(100.0, true)]
    [InlineData(99.9, false)]
    public async Task QuizCompleted_Perfectionist_DependsOnFullSuccess(double percentage, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { SuccessPercentage = percentage });

        result.Contains("perfectionist").Should().Be(expected);
    }

    [Theory]
    [InlineData(3, true)]
    [InlineData(2, false)]
    public async Task QuizCompleted_BusyBee_NeedsThreeTopicsToday(int topicsToday, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { TopicsCompletedToday = topicsToday });

        result.Contains("busy_bee").Should().Be(expected);
    }

    [Theory]
    [InlineData(10, true)]
    [InlineData(9, false)]
    public async Task QuizCompleted_MathMaster_CountsOnlyMathTopics(int mathTopics, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { MathTopicsCompleted = mathTopics });

        result.Contains("math_master").Should().Be(expected);
    }

    [Fact]
    public async Task QuizCompleted_EnglishA1Completed_AwardsWordHunter()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { EnglishA1Completed = true });

        result.Should().Contain("english_a1");
    }

    [Fact]
    public async Task QuizCompleted_EnglishReachedB1_AwardsCefrTraveller()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { EnglishReachedB1 = true });

        result.Should().Contain("english_b1");
    }

    [Theory]
    [InlineData(5, true)]
    [InlineData(6, false)]
    public async Task QuizCompleted_Lightning_NeedsFastAnswer(int seconds, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { QuestionAnswerSeconds = seconds });

        result.Contains("lightning").Should().Be(expected);
    }

    [Theory]
    [InlineData(120, true)]
    [InlineData(121, false)]
    public async Task QuizCompleted_SpeedTrain_NeedsFastQuiz(int seconds, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { QuizDurationSeconds = seconds });

        result.Contains("speed_train").Should().Be(expected);
    }

    [Fact]
    public async Task QuizCompleted_TopicJustCompleted_AwardsTopicMaster()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { TopicJustCompleted = true });

        result.Should().Contain("topic_master");
    }

    [Fact]
    public async Task QuizCompleted_EmptyContext_AwardsNothing()
    {
        var (service, repo) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted, new BadgeTriggerContext());

        result.Should().BeEmpty();
        repo.Verify(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()), Times.Never);
    }

    // ── Streak rozetleri ────────────────────────────────────────────────

    [Theory]
    [InlineData(2, 0)]
    [InlineData(3, 1)]
    [InlineData(7, 2)]
    [InlineData(30, 3)]
    public async Task StreakUpdated_AwardsCumulativeStreakBadges(int streak, int expectedCount)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.StreakUpdated,
            new BadgeTriggerContext { CurrentStreak = streak });

        result.Should().HaveCount(expectedCount);
        if (streak >= 3) result.Should().Contain("streak_3");
        if (streak >= 7) result.Should().Contain("streak_7");
        if (streak >= 30) result.Should().Contain("streak_30");
    }

    // ── Maç rozetleri ───────────────────────────────────────────────────

    [Fact]
    public async Task MatchCompleted_FirstWin_AwardsFirstWin()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = 1, ConsecutiveMatchWins = 1 });

        result.Should().Contain("first_win");
        result.Should().NotContain("win_streak_5");
        result.Should().NotContain("champion_50");
    }

    [Theory]
    [InlineData(4, false)]
    [InlineData(5, true)]
    public async Task MatchCompleted_WinStreak5_NeedsFiveConsecutive(int consecutive, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = consecutive, ConsecutiveMatchWins = consecutive });

        result.Contains("win_streak_5").Should().Be(expected);
    }

    [Theory]
    [InlineData(49, false)]
    [InlineData(50, true)]
    public async Task MatchCompleted_Champion50_NeedsFiftyTotalWins(int totalWins, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = totalWins, ConsecutiveMatchWins = 1 });

        result.Contains("champion_50").Should().Be(expected);
    }

    [Fact]
    public async Task MatchCompleted_NotWon_AwardsNothing()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = false, TotalMatchWins = 99, ConsecutiveMatchWins = 99 });

        result.Should().BeEmpty();
    }

    // ── Meydan okuma rozetleri ──────────────────────────────────────────

    [Fact]
    public async Task ChallengeCompleted_FirstWin_AwardsChallengeFirstWin()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = 1, ConsecutiveChallengeWins = 1 });

        result.Should().Contain("challenge_first_win");
        result.Should().NotContain("challenge_wins_10");
        result.Should().NotContain("challenge_streak_5");
    }

    [Theory]
    [InlineData(9, false)]
    [InlineData(10, true)]
    public async Task ChallengeCompleted_Wins10_NeedsTenTotal(int totalWins, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = totalWins, ConsecutiveChallengeWins = 1 });

        result.Contains("challenge_wins_10").Should().Be(expected);
    }

    [Theory]
    [InlineData(49, false)]
    [InlineData(50, true)]
    public async Task ChallengeCompleted_Wins50_NeedsFiftyTotal(int totalWins, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = totalWins, ConsecutiveChallengeWins = 1 });

        result.Contains("challenge_wins_50").Should().Be(expected);
    }

    [Theory]
    [InlineData(4, false)]
    [InlineData(5, true)]
    public async Task ChallengeCompleted_Streak5_NeedsFiveConsecutive(int consecutive, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = consecutive, ConsecutiveChallengeWins = consecutive });

        result.Contains("challenge_streak_5").Should().Be(expected);
    }

    [Fact]
    public async Task ChallengeCompleted_PerfectWin_AwardsPerfectDuel()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = 1, ConsecutiveChallengeWins = 1, ChallengePerfectWin = true });

        result.Should().Contain("challenge_perfect_win");
    }

    [Theory]
    [InlineData(2, false)]
    [InlineData(3, true)]
    public async Task ChallengeCompleted_Variety_NeedsThreeCategories(int distinctCategories, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = true, TotalChallengeWins = 5, ConsecutiveChallengeWins = 1, DistinctChallengeCategoriesWon = distinctCategories });

        result.Contains("challenge_variety").Should().Be(expected);
    }

    [Fact]
    public async Task ChallengeCompleted_NotWon_AwardsNothing()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ChallengeCompleted,
            new BadgeTriggerContext { ChallengeWon = false, TotalChallengeWins = 99, ConsecutiveChallengeWins = 99, DistinctChallengeCategoriesWon = 9 });

        result.Should().BeEmpty();
    }

    // ── Canlı yarış rozetleri ───────────────────────────────────────────

    [Theory]
    [InlineData(9, false)]
    [InlineData(10, true)]
    public async Task MatchCompleted_LiveMatches10_NeedsTenPlayed_EvenWithoutWin(int played, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = false, TotalLiveMatchesPlayed = played });

        result.Contains("live_matches_10").Should().Be(expected);
    }

    [Theory]
    [InlineData(9, false)]
    [InlineData(10, true)]
    public async Task MatchCompleted_LiveWins10_NeedsTenTotalWins(int totalWins, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = totalWins, ConsecutiveMatchWins = 1 });

        result.Contains("live_wins_10").Should().Be(expected);
    }

    [Theory]
    [InlineData(true, true)]
    [InlineData(false, false)]
    public async Task MatchCompleted_LivePerfectWin_DependsOnFlag(bool perfect, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = 1, ConsecutiveMatchWins = 1, LivePerfectWin = perfect });

        result.Contains("live_perfect_win").Should().Be(expected);
    }

    [Theory]
    [InlineData(true, true)]
    [InlineData(false, false)]
    public async Task MatchCompleted_LiveComeback_DependsOnFlag(bool comeback, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = 1, ConsecutiveMatchWins = 1, LiveComebackWin = comeback });

        result.Contains("live_comeback").Should().Be(expected);
    }

    [Theory]
    [InlineData(2, false)]
    [InlineData(3, true)]
    public async Task MatchCompleted_LiveVariety_NeedsThreeCategories(int distinctCategories, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext { MatchWon = true, TotalMatchWins = 1, ConsecutiveMatchWins = 1, DistinctLiveCategoriesWon = distinctCategories });

        result.Contains("live_variety").Should().Be(expected);
    }

    [Fact]
    public async Task MatchCompleted_NotWon_LiveWonBadgesNotAwarded()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.MatchCompleted,
            new BadgeTriggerContext
            {
                MatchWon = false,
                TotalMatchWins = 99,
                LivePerfectWin = true,
                LiveComebackWin = true,
                DistinctLiveCategoriesWon = 9,
                TotalLiveMatchesPlayed = 3,
            });

        result.Should().NotContain("live_perfect_win");
        result.Should().NotContain("live_comeback");
        result.Should().NotContain("live_wins_10");
        result.Should().NotContain("live_variety");
        result.Should().NotContain("live_matches_10");
    }

    // ── Profil oluşturma ────────────────────────────────────────────────

    [Fact]
    public async Task ProfileCreated_AwardsBetaHero()
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ProfileCreated, new BadgeTriggerContext());

        result.Should().Contain("beta_hero");
    }

    [Theory]
    [InlineData(true, true)]
    [InlineData(false, false)]
    public async Task ProfileCreated_EarlyBird_DependsOnFirst100(bool isAmongFirst100, bool expected)
    {
        var (service, _) = CreateService();

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.ProfileCreated,
            new BadgeTriggerContext { IsAmongFirst100 = isAmongFirst100 });

        result.Should().Contain("beta_hero");
        result.Contains("early_bird").Should().Be(expected);
    }

    // ── İdempotency ─────────────────────────────────────────────────────

    [Fact]
    public async Task AlreadyEarnedBadge_IsNotAwardedAgain()
    {
        var (service, repo) = CreateService(hasEarned: (_, key) => key == "first_quiz");

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { IsEligibleNewQuiz = true });

        result.Should().NotContain("first_quiz");
        repo.Verify(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()), Times.Never);
    }

    [Fact]
    public async Task SameEventProcessedTwice_AwardsBadgeOnlyOnce()
    {
        // İlk çağrıdan sonra rozet kazanılmış sayılır; ikinci çağrı tekrar vermez.
        var earned = new HashSet<string>();
        var (service, repo) = CreateService(hasEarned: (_, key) => earned.Contains(key));
        repo.Setup(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()))
            .Callback(() => { /* AwardAsync çağrı sayısı Verify ile kontrol edilir */ })
            .Returns(Task.CompletedTask);

        var childId = Guid.NewGuid();
        var ctx = new BadgeTriggerContext { TopicJustCompleted = true };

        var first = await service.CheckAndAwardAsync(childId, BadgeTrigger.QuizCompleted, ctx);
        foreach (var key in first) earned.Add(key);
        var second = await service.CheckAndAwardAsync(childId, BadgeTrigger.QuizCompleted, ctx);

        first.Should().Contain("topic_master");
        second.Should().BeEmpty();
        repo.Verify(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()), Times.Once);
    }

    [Fact]
    public async Task RepositoryThrows_DoesNotBubbleUp_ReturnsEmpty()
    {
        var repo = new Mock<IBadgeRepository>();
        repo.Setup(r => r.GetByKeyAsync(It.IsAny<string>())).ThrowsAsync(new Exception("db down"));
        var logger = new Mock<ILogger<BadgeService>>();
        var service = new BadgeService(repo.Object, logger.Object);

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.QuizCompleted,
            new BadgeTriggerContext { IsEligibleNewQuiz = true });

        result.Should().BeEmpty();
    }

    [Fact]
    public async Task OneBadgeFails_OthersStillAwarded()
    {
        var repo = new Mock<IBadgeRepository>();
        repo.Setup(r => r.GetByKeyAsync(It.IsAny<string>()))
            .ReturnsAsync((string key) => new Badge { Id = Guid.NewGuid(), Key = key, IsActive = true });
        repo.Setup(r => r.HasEarnedAsync(It.IsAny<Guid>(), It.IsAny<string>())).ReturnsAsync(false);
        // streak_3 verilirken hata; streak_7 etkilenmemeli
        repo.Setup(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>())).Returns(Task.CompletedTask);
        var logger = new Mock<ILogger<BadgeService>>();
        var service = new BadgeService(repo.Object, logger.Object);

        // GetByKeyAsync("streak_3") çağrısında hata fırlat
        repo.Setup(r => r.GetByKeyAsync("streak_3")).ThrowsAsync(new Exception("boom"));

        var result = await service.CheckAndAwardAsync(
            Guid.NewGuid(), BadgeTrigger.StreakUpdated,
            new BadgeTriggerContext { CurrentStreak = 7 });

        result.Should().NotContain("streak_3");
        result.Should().Contain("streak_7");
    }
}
