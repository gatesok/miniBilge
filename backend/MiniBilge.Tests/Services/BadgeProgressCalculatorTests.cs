using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

public class BadgeProgressCalculatorTests
{
    private static GameStatSnapshot Empty() => new();

    [Theory]
    [InlineData("streak_3", 3)]
    [InlineData("streak_7", 7)]
    [InlineData("streak_30", 30)]
    public void Compute_StreakBadges_UseCurrentStreak(string key, int target)
    {
        var result = BadgeProgressCalculator.Compute(
            key, Empty(), Empty(), Empty(), Empty(), currentStreak: 2);

        result.Should().NotBeNull();
        result!.Target.Should().Be(target);
        result.Current.Should().Be(2);
        result.Unit.Should().Be("days");
    }

    [Fact]
    public void Compute_ChallengeWins10_UsesChallengeTotalWon()
    {
        var challenge = new GameStatSnapshot { TotalWon = 4 };

        var result = BadgeProgressCalculator.Compute(
            "challenge_wins_10", challenge, Empty(), Empty(), Empty(), 0);

        result!.Current.Should().Be(4);
        result.Target.Should().Be(10);
    }

    [Fact]
    public void Compute_ClampsCurrentToTarget()
    {
        var challenge = new GameStatSnapshot { TotalWon = 25 };

        var result = BadgeProgressCalculator.Compute(
            "challenge_wins_10", challenge, Empty(), Empty(), Empty(), 0);

        result!.Current.Should().Be(10);
    }

    [Fact]
    public void Compute_LiveVariety_UsesDistinctCategoriesWon()
    {
        var live = new GameStatSnapshot { DistinctCategoriesWon = 2 };

        var result = BadgeProgressCalculator.Compute(
            "live_variety", Empty(), live, Empty(), Empty(), 0);

        result!.Current.Should().Be(2);
        result.Target.Should().Be(3);
        result.Unit.Should().Be("categories");
    }

    [Fact]
    public void Compute_LiveComeback_ReturnsNull()
    {
        var result = BadgeProgressCalculator.Compute(
            "live_comeback", Empty(), Empty(), Empty(), Empty(), 0);

        result.Should().BeNull();
    }

    [Fact]
    public void Compute_FunQuizzes10_UsesFunAggregateTotalPlayed()
    {
        var fun = new GameStatSnapshot { TotalPlayed = 7 };

        var result = BadgeProgressCalculator.Compute(
            "fun_quizzes_10", Empty(), Empty(), fun, Empty(), 0);

        result!.Current.Should().Be(7);
        result.Target.Should().Be(10);
    }

    [Fact]
    public void Compute_GeneralCultureMaster_UsesGenelKulturCategoryPlayed()
    {
        var funGenel = new GameStatSnapshot { CategoryPlayed = 6 };

        var result = BadgeProgressCalculator.Compute(
            "general_culture_master", Empty(), Empty(), funGenel, Empty(), 0);

        result!.Current.Should().Be(6);
        result.Target.Should().Be(10);
    }

    [Fact]
    public void Compute_WordGameMaster_UsesKelimeCategoryPlayed()
    {
        var funKelime = new GameStatSnapshot { CategoryPlayed = 3 };

        var result = BadgeProgressCalculator.Compute(
            "word_game_master", Empty(), Empty(), Empty(), funKelime, 0);

        result!.Current.Should().Be(3);
        result.Target.Should().Be(10);
    }

    [Fact]
    public void Compute_UnknownOrOldBadge_ReturnsNull()
    {
        var result = BadgeProgressCalculator.Compute(
            "first_quiz", Empty(), Empty(), Empty(), Empty(), 5);

        result.Should().BeNull();
    }
}
