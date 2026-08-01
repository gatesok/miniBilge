using FluentAssertions;
using MiniBilge.Application.Common;
using Xunit;

namespace MiniBilge.Tests.Services;

public class StreakCalculatorTests
{
    private static readonly DateOnly Today = new(2026, 8, 1);

    [Fact]
    public void FirstActivity_StartsAtOne()
    {
        StreakCalculator.Next(0, null, Today).Should().Be(1);
    }

    [Fact]
    public void ActivityYesterday_IncrementsStreak()
    {
        StreakCalculator.Next(5, Today.AddDays(-1), Today).Should().Be(6);
    }

    [Fact]
    public void ActivityToday_DoesNotChangeStreak()
    {
        StreakCalculator.Next(5, Today, Today).Should().Be(5);
    }

    [Fact]
    public void SameDayButStreakZero_NormalizesToOne()
    {
        StreakCalculator.Next(0, Today, Today).Should().Be(1);
    }

    [Theory]
    [InlineData(2)]
    [InlineData(3)]
    [InlineData(10)]
    public void DaySkipped_ResetsToOne(int daysGap)
    {
        StreakCalculator.Next(9, Today.AddDays(-daysGap), Today).Should().Be(1);
    }

    [Fact]
    public void FutureLastActivity_ResetsToOne()
    {
        StreakCalculator.Next(9, Today.AddDays(1), Today).Should().Be(1);
    }

    [Fact]
    public void ConsecutiveDays_ReachStreakMilestones()
    {
        // Ardışık günlerde aktivite ile 3 → 7 → 30 sınırlarına ulaşılabilir.
        var streak = 0;
        DateOnly? last = null;
        for (var i = 0; i < 30; i++)
        {
            var day = Today.AddDays(i);
            streak = StreakCalculator.Next(streak, last, day);
            last = day;
        }
        streak.Should().Be(30);
    }
}
