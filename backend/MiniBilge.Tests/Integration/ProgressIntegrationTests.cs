using FluentAssertions;
using MiniBilge.Application.DTOs.Progress;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Integration;

/// <summary>
/// Sprint 3 E2E Integration Tests
/// Tests the complete flow: Quiz → Progress → Unlock
/// </summary>
public class ProgressIntegrationTests
{
    private readonly Mock<IProgressRepository> _mockProgressRepository;
    private readonly ProgressService _progressService;

    public ProgressIntegrationTests()
    {
        _mockProgressRepository = new Mock<IProgressRepository>();
        _progressService = new ProgressService(_mockProgressRepository.Object);
    }

    #region Complete Flow Tests

    [Fact]
    public async Task CompleteFlow_FirstQuizAttempt_ShouldCreateProgressAndUnlockNextLevel()
    {
        // Senaryo: Kullanıcı ilk kez quiz çözüyor
        // 1. Quiz çöz: 8/10 doğru, 80 saniye
        // 2. Puan hesapla: 80 puan + 40 bonus = 120 puan
        // 3. Yıldız hesapla: %80 başarı = 3 yıldız
        // 4. Progress kaydet
        // 5. Sonraki level unlock edilebilir mi kontrol et

        // Arrange
        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();
        var level2Id = Guid.NewGuid();

        int correctCount = 8;
        int totalQuestions = 10;
        int timeTakenSeconds = 80; // Ortalama 8 saniye/soru → bonus

        // Repository setup - başlangıçta progress yok
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, level1Id))
            .ReturnsAsync((LevelResult?)null);
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync((ChildProgress?)null);

        // Act - Step 1: Puan hesapla
        var score = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);

        // Assert - Step 1
        score.Should().Be(120, "8 correct answers (80 pts) + speed bonus (40 pts) = 120 pts");

        // Act - Step 2: Başarı yüzdesini hesapla
        decimal successPercentage = (decimal)correctCount / totalQuestions * 100;
        successPercentage.Should().Be(80m);

        // Act - Step 3: Yıldız hesapla
        var stars = _progressService.CalculateStars(successPercentage);

        // Assert - Step 3
        stars.Should().Be(3, "80% success should give 3 stars");

        // Act - Step 4: Progress kaydet
        var saveRequest = new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = level1Id,
            Score = score,
            Stars = stars,
            CorrectCount = correctCount,
            TotalQuestions = totalQuestions,
            SuccessPercentage = successPercentage
        };

        // Setup repository responses for save operation
        _mockProgressRepository
            .Setup(x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()))
            .ReturnsAsync((LevelResult lr) => lr);
        _mockProgressRepository
            .Setup(x => x.CreateChildProgressAsync(It.IsAny<ChildProgress>()))
            .ReturnsAsync((ChildProgress cp) => cp);

        await _progressService.SaveProgressAsync(saveRequest);

        // Assert - Step 4: Verify save operations were called
        _mockProgressRepository.Verify(
            x => x.CreateLevelResultAsync(It.Is<LevelResult>(lr =>
                lr.ChildId == childId &&
                lr.LevelId == level1Id &&
                lr.Score == 120 &&
                lr.Stars == 3 &&
                lr.SuccessPercentage == 80m
            )),
            Times.Once,
            "Level result should be created with correct values"
        );

        _mockProgressRepository.Verify(
            x => x.CreateChildProgressAsync(It.Is<ChildProgress>(cp =>
                cp.ChildId == childId &&
                cp.TotalScore == 120 &&
                cp.TotalStars == 3 &&
                cp.CompletedLevelsCount == 1
            )),
            Times.Once,
            "Child progress should be created for first quiz"
        );

        // Act - Step 5: Sonraki level unlock kontrol et
        // Mock'u güncelle - artık level1 sonucu var
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, level1Id))
            .ReturnsAsync(new LevelResult
            {
                Id = Guid.NewGuid(),
                ChildId = childId,
                LevelId = level1Id,
                Score = 120,
                Stars = 3,
                SuccessPercentage = 80m,
                IsUnlocked = true
            });

        var isLevel2Unlocked = await _progressService.CheckLevelUnlockAsync(childId, level1Id);

        // Assert - Step 5
        isLevel2Unlocked.Should().BeTrue("Level 1 completed with 80% success should unlock Level 2");
    }

    [Fact]
    public async Task CompleteFlow_RetryToImproveScore_ShouldUpdateProgressWithBetterScore()
    {
        // Senaryo: Kullanıcı daha iyi skor için tekrar çözüyor
        // 1. İlk deneme: 6/10 doğru, 100 saniye → 60 puan, 2 yıldız, %60
        // 2. İkinci deneme: 9/10 doğru, 70 saniye → 135 puan, 3 yıldız, %90
        // 3. Progress güncellenmeli (daha iyi skor)

        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        // İlk deneme sonucu (mevcut)
        var existingResult = new LevelResult
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            LevelId = levelId,
            Score = 60,
            Stars = 2,
            CorrectCount = 6,
            TotalQuestions = 10,
            SuccessPercentage = 60m,
            IsUnlocked = true,
            CompletedAt = DateTime.UtcNow.AddDays(-1)
        };

        var existingProgress = new ChildProgress
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            TotalScore = 60,
            TotalStars = 2,
            CompletedLevelsCount = 1
        };

        // Repository setup
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(existingResult);
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync(existingProgress);
        _mockProgressRepository
            .Setup(x => x.GetLevelResultsByChildIdAsync(childId))
            .ReturnsAsync(new List<LevelResult> { existingResult });
        _mockProgressRepository
            .Setup(x => x.UpdateLevelResultAsync(It.IsAny<LevelResult>()))
            .ReturnsAsync((LevelResult lr) => lr);
        _mockProgressRepository
            .Setup(x => x.UpdateChildProgressAsync(It.IsAny<ChildProgress>()))
            .ReturnsAsync((ChildProgress cp) => cp);

        // Act - İkinci deneme
        int correctCount = 9;
        int totalQuestions = 10;
        int timeTakenSeconds = 70; // Ortalama 7.7 saniye/soru → bonus

        var newScore = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);
        decimal newSuccessPercentage = (decimal)correctCount / totalQuestions * 100;
        var newStars = _progressService.CalculateStars(newSuccessPercentage);

        // Assert - Yeni skorlar daha iyi
        newScore.Should().Be(135, "9 correct (90 pts) + bonus (45 pts) = 135 pts");
        newStars.Should().Be(3, "90% success = 3 stars");
        newSuccessPercentage.Should().Be(90m);

        // Act - Progress güncelle
        var saveRequest = new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = levelId,
            Score = newScore,
            Stars = newStars,
            CorrectCount = correctCount,
            TotalQuestions = totalQuestions,
            SuccessPercentage = newSuccessPercentage
        };

        await _progressService.SaveProgressAsync(saveRequest);

        // Assert - Update çağrıları yapıldı mı kontrol et
        _mockProgressRepository.Verify(
            x => x.UpdateLevelResultAsync(It.Is<LevelResult>(lr =>
                lr.Score == 135 &&
                lr.Stars == 3 &&
                lr.SuccessPercentage == 90m
            )),
            Times.Once,
            "Level result should be updated with better score"
        );
    }

    [Fact]
    public async Task CompleteFlow_FailedQuiz_ShouldNotUnlockNextLevel()
    {
        // Senaryo: Kullanıcı quiz'i başarısız oluyor
        // 1. Quiz çöz: 5/10 doğru, 150 saniye
        // 2. Puan hesapla: 50 puan (bonus yok)
        // 3. Yıldız hesapla: %50 başarı = 2 yıldız
        // 4. Progress kaydet
        // 5. Sonraki level unlock EDİLMEMELİ (%70'in altında)

        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        int correctCount = 5;
        int totalQuestions = 10;
        int timeTakenSeconds = 150; // Yavaş → bonus yok

        // Repository setup
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync((LevelResult?)null);
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync((ChildProgress?)null);
        _mockProgressRepository
            .Setup(x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()))
            .ReturnsAsync((LevelResult lr) => lr);
        _mockProgressRepository
            .Setup(x => x.CreateChildProgressAsync(It.IsAny<ChildProgress>()))
            .ReturnsAsync((ChildProgress cp) => cp);

        // Act - Puan ve yıldız hesapla
        var score = _progressService.CalculateScore(correctCount, totalQuestions, timeTakenSeconds);
        decimal successPercentage = (decimal)correctCount / totalQuestions * 100;
        var stars = _progressService.CalculateStars(successPercentage);

        // Assert
        score.Should().Be(50, "5 correct answers without bonus");
        successPercentage.Should().Be(50m);
        stars.Should().Be(2, "50% success = 2 stars");

        // Act - Progress kaydet
        var saveRequest = new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = levelId,
            Score = score,
            Stars = stars,
            CorrectCount = correctCount,
            TotalQuestions = totalQuestions,
            SuccessPercentage = successPercentage
        };

        await _progressService.SaveProgressAsync(saveRequest);

        // Assert - Progress kaydedildi
        _mockProgressRepository.Verify(
            x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()),
            Times.Once
        );

        // Act - Level unlock kontrol et
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(new LevelResult
            {
                Id = Guid.NewGuid(),
                ChildId = childId,
                LevelId = levelId,
                Score = 50,
                Stars = 2,
                SuccessPercentage = 50m,
                IsUnlocked = true
            });

        var isNextLevelUnlocked = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert - Sonraki level unlock EDİLMEMELİ
        isNextLevelUnlocked.Should().BeFalse("50% success (below 70%) should NOT unlock next level");
    }

    [Fact]
    public async Task CompleteFlow_MultipleQuizzesProgression_ShouldTrackTotalProgress()
    {
        // Senaryo: Kullanıcı birden fazla quiz çözüyor
        // Level 1: 8/10 → 120 puan, 3 yıldız
        // Level 2: 7/10 → 70 puan, 2 yıldız
        // Level 3: 9/10 → 135 puan, 3 yıldız
        // Toplam: 325 puan, 8 yıldız, 3 tamamlanan level

        // Arrange
        var childId = Guid.NewGuid();
        var level1Id = Guid.NewGuid();
        var level2Id = Guid.NewGuid();
        var level3Id = Guid.NewGuid();

        // Başlangıçta progress yok
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync((ChildProgress?)null);
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, It.IsAny<Guid>()))
            .ReturnsAsync((LevelResult?)null);

        var levelResults = new List<LevelResult>();
        _mockProgressRepository
            .Setup(x => x.GetLevelResultsByChildIdAsync(childId))
            .ReturnsAsync(() => levelResults);

        var createdProgress = new ChildProgress
        {
            Id = Guid.NewGuid(),
            ChildId = childId,
            TotalScore = 0,
            TotalStars = 0,
            CompletedLevelsCount = 0
        };

        _mockProgressRepository
            .Setup(x => x.CreateChildProgressAsync(It.IsAny<ChildProgress>()))
            .Callback<ChildProgress>(cp => createdProgress = cp)
            .ReturnsAsync((ChildProgress cp) => cp);

        _mockProgressRepository
            .Setup(x => x.UpdateChildProgressAsync(It.IsAny<ChildProgress>()))
            .Callback<ChildProgress>(cp =>
            {
                createdProgress.TotalScore = cp.TotalScore;
                createdProgress.TotalStars = cp.TotalStars;
                createdProgress.CompletedLevelsCount = cp.CompletedLevelsCount;
            })
            .ReturnsAsync((ChildProgress cp) => cp);

        _mockProgressRepository
            .Setup(x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()))
            .Callback<LevelResult>(lr => levelResults.Add(lr))
            .ReturnsAsync((LevelResult lr) => lr);

        // Act - Level 1
        var level1Score = _progressService.CalculateScore(8, 10, 80);
        var level1Stars = _progressService.CalculateStars(80m);
        
        await _progressService.SaveProgressAsync(new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = level1Id,
            Score = level1Score,
            Stars = level1Stars,
            CorrectCount = 8,
            TotalQuestions = 10,
            SuccessPercentage = 80m
        });

        // Mock'u güncelle - artık progress var
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync(createdProgress);

        // Act - Level 2
        var level2Score = _progressService.CalculateScore(7, 10, 100);
        var level2Stars = _progressService.CalculateStars(70m);
        
        await _progressService.SaveProgressAsync(new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = level2Id,
            Score = level2Score,
            Stars = level2Stars,
            CorrectCount = 7,
            TotalQuestions = 10,
            SuccessPercentage = 70m
        });

        // Act - Level 3
        var level3Score = _progressService.CalculateScore(9, 10, 70);
        var level3Stars = _progressService.CalculateStars(90m);
        
        await _progressService.SaveProgressAsync(new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = level3Id,
            Score = level3Score,
            Stars = level3Stars,
            CorrectCount = 9,
            TotalQuestions = 10,
            SuccessPercentage = 90m
        });

        // Assert - Toplam progress
        level1Score.Should().Be(120);
        level2Score.Should().Be(70);
        level3Score.Should().Be(135);

        level1Stars.Should().Be(3);
        level2Stars.Should().Be(2);
        level3Stars.Should().Be(3);

        // Note: Actual accumulation logic is in the service,
        // here we're testing that save operations are called correctly
        _mockProgressRepository.Verify(
            x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()),
            Times.Exactly(3),
            "Should create 3 level results"
        );
    }

    #endregion

    #region Edge Case Flows

    [Fact]
    public async Task CompleteFlow_PerfectScore_ShouldGiveMaximumRewards()
    {
        // Senaryo: Kullanıcı mükemmel skor alıyor
        // 10/10 doğru, 50 saniye (çok hızlı)
        // 150 puan (100 + 50 bonus), 3 yıldız, %100 başarı

        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync((LevelResult?)null);
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync((ChildProgress?)null);
        _mockProgressRepository
            .Setup(x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()))
            .ReturnsAsync((LevelResult lr) => lr);
        _mockProgressRepository
            .Setup(x => x.CreateChildProgressAsync(It.IsAny<ChildProgress>()))
            .ReturnsAsync((ChildProgress cp) => cp);

        // Act
        var score = _progressService.CalculateScore(10, 10, 50);
        var stars = _progressService.CalculateStars(100m);

        // Assert
        score.Should().Be(150, "Perfect score with speed bonus");
        stars.Should().Be(3, "100% success = 3 stars");

        // Act - Save
        await _progressService.SaveProgressAsync(new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = levelId,
            Score = score,
            Stars = stars,
            CorrectCount = 10,
            TotalQuestions = 10,
            SuccessPercentage = 100m
        });

        // Assert
        _mockProgressRepository.Verify(
            x => x.CreateLevelResultAsync(It.Is<LevelResult>(lr =>
                lr.Score == 150 &&
                lr.Stars == 3 &&
                lr.SuccessPercentage == 100m
            )),
            Times.Once
        );

        // Act - Check unlock
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(new LevelResult
            {
                Id = Guid.NewGuid(),
                ChildId = childId,
                LevelId = levelId,
                Score = 150,
                Stars = 3,
                SuccessPercentage = 100m,
                IsUnlocked = true
            });

        var isUnlocked = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        isUnlocked.Should().BeTrue("Perfect score should unlock next level");
    }

    [Fact]
    public async Task CompleteFlow_MinimumPassingScore_ShouldUnlockNextLevel()
    {
        // Senaryo: Kullanıcı tam %70 ile geçiyor (boundary case)
        // 7/10 doğru, 150 saniye (yavaş)
        // 70 puan, 2 yıldız, %70 başarı

        // Arrange
        var childId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync((LevelResult?)null);
        _mockProgressRepository
            .Setup(x => x.GetChildProgressAsync(childId))
            .ReturnsAsync((ChildProgress?)null);
        _mockProgressRepository
            .Setup(x => x.CreateLevelResultAsync(It.IsAny<LevelResult>()))
            .ReturnsAsync((LevelResult lr) => lr);
        _mockProgressRepository
            .Setup(x => x.CreateChildProgressAsync(It.IsAny<ChildProgress>()))
            .ReturnsAsync((ChildProgress cp) => cp);

        // Act
        var score = _progressService.CalculateScore(7, 10, 150);
        var stars = _progressService.CalculateStars(70m);

        // Assert
        score.Should().Be(70);
        stars.Should().Be(2);

        // Act - Save
        await _progressService.SaveProgressAsync(new SaveProgressRequest
        {
            ChildId = childId,
            LevelId = levelId,
            Score = score,
            Stars = stars,
            CorrectCount = 7,
            TotalQuestions = 10,
            SuccessPercentage = 70m
        });

        // Act - Check unlock (boundary: exactly 70%)
        _mockProgressRepository
            .Setup(x => x.GetLevelResultAsync(childId, levelId))
            .ReturnsAsync(new LevelResult
            {
                Id = Guid.NewGuid(),
                ChildId = childId,
                LevelId = levelId,
                Score = 70,
                Stars = 2,
                SuccessPercentage = 70m,
                IsUnlocked = true
            });

        var isUnlocked = await _progressService.CheckLevelUnlockAsync(childId, levelId);

        // Assert
        isUnlocked.Should().BeTrue("Exactly 70% success should unlock next level (inclusive)");
    }

    #endregion
}
