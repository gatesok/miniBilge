using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class ProgressServiceTests
{
    private readonly Mock<IProgressRepository> _mockProgressRepository;
    private readonly ProgressService _progressService;

    public ProgressServiceTests()
    {
        _mockProgressRepository = new Mock<IProgressRepository>();
        _progressService = new ProgressService(_mockProgressRepository.Object);
    }

    #region CalculateScore Tests

    [Fact]
    public void CalculateScore_WithNoCorrectAnswers_ShouldReturn0()
    {
        // Arrange
        int correctCount = 0;
        int totalQuestions = 10;

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateScore_WithAllCorrectAnswers_ShouldReturnCorrectScore()
    {
        // Arrange
        int correctCount = 10;
        int totalQuestions = 10;
        int expectedScore = 10 * 10; // Her doğru +10 puan

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions);

        // Assert
        result.Should().Be(expectedScore);
    }

    [Fact]
    public void CalculateScore_WithPartialCorrectAnswers_ShouldReturnCorrectScore()
    {
        // Arrange
        int correctCount = 7;
        int totalQuestions = 10;
        int expectedScore = 7 * 10; // Her doğru +10 puan

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions);

        // Assert
        result.Should().Be(expectedScore);
    }

    [Fact]
    public void CalculateScore_WithSpeedBonus_ShouldAddBonusPoints()
    {
        // Arrange
        int correctCount = 10;
        int totalQuestions = 10;
        int timeTakenSeconds = 50; // 10 soru, 50 saniye = ortalama 5 saniye/soru (threshold 10 saniye)
        int baseScore = 10 * 10; // 100 puan
        int bonusScore = 10 * 5; // Her doğru için +5 bonus = 50 puan
        int expectedScore = baseScore + bonusScore; // 150 puan

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Assert
        result.Should().Be(expectedScore);
    }

    [Fact]
    public void CalculateScore_WithSlowAnswers_ShouldNotAddBonusPoints()
    {
        // Arrange
        int correctCount = 10;
        int totalQuestions = 10;
        int timeTakenSeconds = 150; // 10 soru, 150 saniye = ortalama 15 saniye/soru (threshold 10 saniye)
        int expectedScore = 10 * 10; // Sadece base score, bonus yok

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Assert
        result.Should().Be(expectedScore);
    }

    [Fact]
    public void CalculateScore_WithNegativeCorrectCount_ShouldReturn0()
    {
        // Arrange
        int correctCount = -5;
        int totalQuestions = 10;

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateScore_WithZeroTotalQuestions_ShouldReturn0()
    {
        // Arrange
        int correctCount = 5;
        int totalQuestions = 0;

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateScore_WithExactThresholdTime_ShouldAddBonusPoints()
    {
        // Arrange
        int correctCount = 10;
        int totalQuestions = 10;
        int timeTakenSeconds = 100; // 10 soru, 100 saniye = ortalama 10 saniye/soru (tam threshold)
        int baseScore = 10 * 10; // 100 puan
        int bonusScore = 10 * 5; // Her doğru için +5 bonus = 50 puan
        int expectedScore = baseScore + bonusScore; // 150 puan

        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Assert
        result.Should().Be(expectedScore);
    }

    [Theory]
    [InlineData(5, 10, 30, 75)]  // 5 doğru, 30 saniye = ortalama 6 saniye → bonus
    [InlineData(8, 10, 64, 120)] // 8 doğru, 64 saniye = ortalama 8 saniye → bonus
    [InlineData(3, 10, 15, 45)]  // 3 doğru, 15 saniye = ortalama 5 saniye → bonus
    [InlineData(10, 10, 110, 100)] // 10 doğru, 110 saniye = ortalama 11 saniye → no bonus
    public void CalculateScore_WithVariousScenarios_ShouldReturnCorrectScore(
        int correctCount, int totalQuestions, int timeTakenSeconds, int expectedScore)
    {
        // Act
        var result = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Assert
        result.Should().Be(expectedScore);
    }

    #endregion

    #region CalculateStars Tests

    [Fact]
    public void CalculateStars_WithLessThan30Percent_ShouldReturn0Stars()
    {
        // Arrange
        decimal successPercentage = 25m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateStars_WithExactly30Percent_ShouldReturn1Star()
    {
        // Arrange
        decimal successPercentage = 30m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(1);
    }

    [Fact]
    public void CalculateStars_WithBetween30And50Percent_ShouldReturn1Star()
    {
        // Arrange
        decimal successPercentage = 40m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(1);
    }

    [Fact]
    public void CalculateStars_WithExactly50Percent_ShouldReturn2Stars()
    {
        // Arrange
        decimal successPercentage = 50m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(2);
    }

    [Fact]
    public void CalculateStars_WithBetween50And80Percent_ShouldReturn2Stars()
    {
        // Arrange
        decimal successPercentage = 65m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(2);
    }

    [Fact]
    public void CalculateStars_WithExactly80Percent_ShouldReturn3Stars()
    {
        // Arrange
        decimal successPercentage = 80m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(3);
    }

    [Fact]
    public void CalculateStars_WithMoreThan80Percent_ShouldReturn3Stars()
    {
        // Arrange
        decimal successPercentage = 95m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(3);
    }

    [Fact]
    public void CalculateStars_With100Percent_ShouldReturn3Stars()
    {
        // Arrange
        decimal successPercentage = 100m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(3);
    }

    [Fact]
    public void CalculateStars_WithNegativePercentage_ShouldReturn0Stars()
    {
        // Arrange
        decimal successPercentage = -10m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateStars_WithMoreThan100Percent_ShouldReturn0Stars()
    {
        // Arrange
        decimal successPercentage = 150m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(0);
    }

    [Fact]
    public void CalculateStars_WithZeroPercent_ShouldReturn0Stars()
    {
        // Arrange
        decimal successPercentage = 0m;

        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(0);
    }

    [Theory]
    [InlineData(0, 0)]
    [InlineData(29.9, 0)]
    [InlineData(30, 1)]
    [InlineData(49.9, 1)]
    [InlineData(50, 2)]
    [InlineData(79.9, 2)]
    [InlineData(80, 3)]
    [InlineData(100, 3)]
    public void CalculateStars_WithVariousPercentages_ShouldReturnCorrectStars(
        decimal successPercentage, int expectedStars)
    {
        // Act
        var result = _progressService.CalculateStars(successPercentage);

        // Assert
        result.Should().Be(expectedStars);
    }

    #endregion

    #region Integration Tests

    [Theory]
    [InlineData(10, 10, 50, 150, 100, 3)]  // Mükemmel: 10/10, hızlı, 150 puan, 3 yıldız
    [InlineData(8, 10, 64, 120, 80, 3)]    // Mükemmel: 8/10, hızlı, 120 puan, 3 yıldız
    [InlineData(7, 10, 100, 70, 70, 2)]    // İyi: 7/10, yavaş, 70 puan, 2 yıldız
    [InlineData(5, 10, 80, 50, 50, 2)]     // İyi: 5/10, yavaş, 50 puan, 2 yıldız
    [InlineData(3, 10, 50, 30, 30, 1)]     // Zayıf: 3/10, yavaş, 30 puan, 1 yıldız
    [InlineData(2, 10, 30, 20, 20, 0)]     // Çok Zayıf: 2/10, yavaş, 20 puan, 0 yıldız
    public void ScoreAndStars_Integration_ShouldCalculateCorrectly(
        int correctCount,
        int totalQuestions,
        int timeTakenSeconds,
        int expectedScore,
        decimal expectedSuccessPercentage,
        int expectedStars)
    {
        // Act - Calculate Score
        var score = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Calculate Success Percentage
        decimal successPercentage = (decimal)correctCount / totalQuestions * 100;

        // Act - Calculate Stars
        var stars = _progressService.CalculateStars(successPercentage);

        // Assert
        score.Should().Be(expectedScore, $"Score should be {expectedScore} for {correctCount}/{totalQuestions} correct answers");
        successPercentage.Should().Be(expectedSuccessPercentage, $"Success percentage should be {expectedSuccessPercentage}%");
        stars.Should().Be(expectedStars, $"Stars should be {expectedStars} for {expectedSuccessPercentage}% success");
    }

    #endregion
}
