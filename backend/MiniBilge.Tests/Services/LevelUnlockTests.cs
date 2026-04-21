using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class LevelUnlockTests
{
    private readonly Mock<IProgressRepository> _mockProgressRepository;
    private readonly ProgressService _progressService;

    public LevelUnlockTests()
    {
        _mockProgressRepository = new Mock<IProgressRepository>();
        _progressService = new ProgressService(_mockProgressRepository.Object);
    }

    #region CheckLevelUnlockAsync Tests

    [Fact]
    public async Task CheckLevelUnlock_WhenLevelNotCompleted_ShouldReturnFalse()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync((LevelResult?)null);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeFalse("level has not been completed yet");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenCompletedWith70PercentSuccess_ShouldReturnTrue()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 70,
            Stars = 2,
            CorrectCount = 7,
            TotalQuestions = 10,
            SuccessPercentage = 70m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeTrue("level completed with exactly 70% success");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenCompletedWithMoreThan70Percent_ShouldReturnTrue()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 85,
            Stars = 3,
            CorrectCount = 85,
            TotalQuestions = 100,
            SuccessPercentage = 85m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeTrue("level completed with 85% success (above threshold)");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenCompletedWithLessThan70Percent_ShouldReturnFalse()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 50,
            Stars = 2,
            CorrectCount = 5,
            TotalQuestions = 10,
            SuccessPercentage = 50m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeFalse("level completed with only 50% success (below 70% threshold)");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenCompletedWith69Point9Percent_ShouldReturnFalse()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 69,
            Stars = 2,
            CorrectCount = 699,
            TotalQuestions = 1000,
            SuccessPercentage = 69.9m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeFalse("level completed with 69.9% success (just below threshold)");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenCompletedWith100Percent_ShouldReturnTrue()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 100,
            Stars = 3,
            CorrectCount = 10,
            TotalQuestions = 10,
            SuccessPercentage = 100m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().BeTrue("level completed with perfect 100% success");
    }

    [Theory]
    [InlineData(0, false)]      // 0% → locked
    [InlineData(30, false)]     // 30% → locked
    [InlineData(50, false)]     // 50% → locked
    [InlineData(69, false)]     // 69% → locked
    [InlineData(69.9, false)]   // 69.9% → locked (boundary)
    [InlineData(70, true)]      // 70% → unlocked (threshold)
    [InlineData(70.1, true)]    // 70.1% → unlocked
    [InlineData(80, true)]      // 80% → unlocked
    [InlineData(90, true)]      // 90% → unlocked
    [InlineData(100, true)]     // 100% → unlocked
    public async Task CheckLevelUnlock_WithVariousSuccessPercentages_ShouldReturnCorrectStatus(
        decimal successPercentage, bool expectedUnlockStatus)
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        var levelResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = (int)successPercentage,
            Stars = successPercentage >= 80 ? 3 : successPercentage >= 50 ? 2 : successPercentage >= 30 ? 1 : 0,
            CorrectCount = (int)successPercentage,
            TotalQuestions = 100,
            SuccessPercentage = successPercentage,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow
        };

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(levelResult);

        // Act
        var result = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        result.Should().Be(expectedUnlockStatus, 
            $"level with {successPercentage}% success should be {(expectedUnlockStatus ? "unlocked" : "locked")}");
    }

    #endregion

    #region Level Unlock Sequence Tests

    [Fact]
    public async Task LevelUnlockSequence_Scenario1_PerfectProgression()
    {
        // Senaryo: Kullanıcı tüm seviyeleri %70+ ile tamamlıyor
        // Level 1 → 80% → Level 2 unlock
        // Level 2 → 75% → Level 3 unlock
        // Level 3 → 90% → Level 4 unlock

        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();
        var level2Id = Guid.NewGuid();
        var level3Id = Guid.NewGuid();

        // Level 1: 80% başarı
        var level1Result = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level1Id,
            SuccessPercentage = 80m,
            IsUnlocked = true
        };

        // Level 2: 75% başarı
        var level2Result = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level2Id,
            SuccessPercentage = 75m,
            IsUnlocked = true
        };

        // Level 3: 90% başarı
        var level3Result = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level3Id,
            SuccessPercentage = 90m,
            IsUnlocked = true
        };

        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level1Id)).ReturnsAsync(level1Result);
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level2Id)).ReturnsAsync(level2Result);
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level3Id)).ReturnsAsync(level3Result);

        // Act & Assert
        (await _progressService.CheckLevelUnlockAsync(childId, level1Id)).Should().BeTrue("Level 1 completed with 80%");
        (await _progressService.CheckLevelUnlockAsync(childId, level2Id)).Should().BeTrue("Level 2 completed with 75%");
        (await _progressService.CheckLevelUnlockAsync(childId, level3Id)).Should().BeTrue("Level 3 completed with 90%");
    }

    [Fact]
    public async Task LevelUnlockSequence_Scenario2_FailedAtLevel2()
    {
        // Senaryo: Kullanıcı Level 2'de %70'in altında kalıyor
        // Level 1 → 80% → Level 2 unlock
        // Level 2 → 60% → Level 3 LOCKED (yeterli başarı yok)

        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();
        var level2Id = Guid.NewGuid();
        var level3Id = Guid.NewGuid();

        // Level 1: 80% başarı
        var level1Result = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level1Id,
            SuccessPercentage = 80m,
            IsUnlocked = true
        };

        // Level 2: 60% başarı (yetersiz!)
        var level2Result = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level2Id,
            SuccessPercentage = 60m,
            IsUnlocked = true
        };

        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level1Id)).ReturnsAsync(level1Result);
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level2Id)).ReturnsAsync(level2Result);
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level3Id)).ReturnsAsync((LevelResult?)null);

        // Act & Assert
        (await _progressService.CheckLevelUnlockAsync(childId, level1Id)).Should().BeTrue("Level 1 completed successfully");
        (await _progressService.CheckLevelUnlockAsync(childId, level2Id)).Should().BeFalse("Level 2 completed with insufficient 60% (below 70%)");
        (await _progressService.CheckLevelUnlockAsync(childId, level3Id)).Should().BeFalse("Level 3 not completed yet");
    }

    [Fact]
    public async Task LevelUnlockSequence_Scenario3_RetryAndImprove()
    {
        // Senaryo: Kullanıcı ilk denemede başarısız, tekrar deniyor
        // Level 1 (1st attempt) → 60% → Level 2 LOCKED
        // Level 1 (2nd attempt) → 75% → Level 2 UNLOCKED

        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();

        // İlk deneme: 60% başarı
        var level1FirstAttempt = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level1Id,
            SuccessPercentage = 60m,
            IsUnlocked = true
        };

        // İkinci deneme: 75% başarı (gelişti!)
        var level1SecondAttempt = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = level1Id,
            SuccessPercentage = 75m,
            IsUnlocked = true
        };

        // İlk deneme sonrası
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level1Id)).ReturnsAsync(level1FirstAttempt);
        var firstResult = await _progressService.CheckLevelUnlockAsync(childId, level1Id);
        firstResult.Should().BeFalse("First attempt with 60% should not unlock next level");

        // İkinci deneme sonrası (mock'u güncelle)
        _mockProgressRepository.Setup(x => x.GetLevelResultAsync(childId, level1Id)).ReturnsAsync(level1SecondAttempt);
        var secondResult = await _progressService.CheckLevelUnlockAsync(childId, level1Id);
        secondResult.Should().BeTrue("Second attempt with 75% should unlock next level");
    }

    #endregion

    #region Edge Cases

    [Fact]
    public async Task CheckLevelUnlock_WithNewChild_ShouldReturnFalseForAllLevels()
    {
        // Arrange - Yeni çocuk, hiç progress yok
        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();
        var level2Id = Guid.NewGuid();

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, It.IsAny<Guid>()))
            .ReturnsAsync((LevelResult?)null);

        // Act & Assert
        (await _progressService.CheckLevelUnlockAsync(childId, level1Id)).Should().BeFalse("New child has no progress");
        (await _progressService.CheckLevelUnlockAsync(childId, level2Id)).Should().BeFalse("New child has no progress");
    }

    [Fact]
    public async Task CheckLevelUnlock_WhenRepositoryThrowsException_ShouldPropagateException()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ThrowsAsync(new Exception("Database connection failed"));

        // Act & Assert
        await FluentActions.Invoking(async () => 
            await _progressService.CheckLevelUnlockAsync(childId, levelId))
            .Should().ThrowAsync<Exception>()
            .WithMessage("Database connection failed");
    }

    #endregion
}
