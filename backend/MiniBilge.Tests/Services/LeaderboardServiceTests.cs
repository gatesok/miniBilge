using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class LeaderboardServiceTests
{
    private readonly Mock<IChildProfileRepository> _mockChildProfileRepository;
    private readonly Mock<IProgressRepository> _mockProgressRepository;
    private readonly LeaderboardService _leaderboardService;

    public LeaderboardServiceTests()
    {
        _mockChildProfileRepository = new Mock<IChildProfileRepository>();
        _mockProgressRepository = new Mock<IProgressRepository>();
        _leaderboardService = new LeaderboardService(
            _mockChildProfileRepository.Object,
            _mockProgressRepository.Object);
    }

    private static ChildProfile CreateChild(string name, int totalCoins, int totalStars = 0) => new()
    {
        Id = Guid.NewGuid(),
        Name = name,
        TotalCoins = totalCoins,
        TotalStars = totalStars,
        GradeLevel = GradeLevel.Grade1,
        DateOfBirth = DateTime.UtcNow.AddYears(-7),
        ParentProfileId = Guid.NewGuid()
    };

    private static List<ChildProgress> BuildProgressMap(IEnumerable<ChildProfile> children, Func<ChildProfile, int>? scoreSelector = null)
    {
        return children.Select(c => new ChildProgress
        {
            Id = Guid.NewGuid(),
            ChildId = c.Id,
            TotalScore = scoreSelector?.Invoke(c) ?? c.TotalCoins,
            TotalStars = c.TotalStars,
        }).ToList();
    }

    // Test 1: TotalScore'a göre sıralama doğru mu?
    [Fact]
    public async Task GetTopN_WithMultipleChildren_ShouldReturnSortedByTotalScore()
    {
        // Arrange
        var children = new List<ChildProfile>
        {
            CreateChild("Ali", 50),
            CreateChild("Veli", 200),
            CreateChild("Ayşe", 150),
        };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetTopNAsync(10);

        // Assert
        result.Should().HaveCount(3);
        result[0].ChildName.Should().Be("Veli");
        result[0].Rank.Should().Be(1);
        result[1].ChildName.Should().Be("Ayşe");
        result[1].Rank.Should().Be(2);
        result[2].ChildName.Should().Be("Ali");
        result[2].Rank.Should().Be(3);
    }

    // Test 2: Eşit TotalScore'da yıldıza göre sıralama
    [Fact]
    public async Task GetTopN_WithEqualScore_ShouldSortByStars()
    {
        // Arrange
        var children = new List<ChildProfile>
        {
            CreateChild("Ali", 100, totalStars: 2),
            CreateChild("Veli", 100, totalStars: 5),
            CreateChild("Ayşe", 100, totalStars: 1),
        };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetTopNAsync(10);

        // Assert
        result[0].ChildName.Should().Be("Veli");
        result[1].ChildName.Should().Be("Ali");
        result[2].ChildName.Should().Be("Ayşe");
    }

    // Test 3: N > liste büyüklüğü ise tümü dönmeli
    [Fact]
    public async Task GetTopN_WhenNBiggerThanList_ShouldReturnAll()
    {
        // Arrange
        var children = new List<ChildProfile>
        {
            CreateChild("Ali", 100),
            CreateChild("Veli", 200),
        };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetTopNAsync(50);

        // Assert
        result.Should().HaveCount(2);
    }

    // Test 4: Boş liste
    [Fact]
    public async Task GetTopN_WithEmptyList_ShouldReturnEmpty()
    {
        // Arrange
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(new List<ChildProfile>());
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(new List<ChildProgress>());

        // Act
        var result = await _leaderboardService.GetTopNAsync(10);

        // Assert
        result.Should().BeEmpty();
    }

    // Test 5: Çocuğun sırası doğru mu?
    [Fact]
    public async Task GetChildRank_WhenChildExists_ShouldReturnCorrectRank()
    {
        // Arrange
        var targetChild = CreateChild("Hedef Çocuk", 150);
        var children = new List<ChildProfile>
        {
            CreateChild("Birinci", 300),
            targetChild,
            CreateChild("Üçüncü", 50),
        };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetChildRankAsync(targetChild.Id);

        // Assert
        result.Should().NotBeNull();
        result!.Rank.Should().Be(2);
        result.ChildName.Should().Be("Hedef Çocuk");
        result.TotalScore.Should().Be(150);
    }

    // Test 6: Birinci sıradaki çocuğun rank'ı 1 olmalı
    [Fact]
    public async Task GetChildRank_WhenChildIsFirst_ShouldReturnRank1()
    {
        // Arrange
        var topChild = CreateChild("Birinci", 500);
        var children = new List<ChildProfile>
        {
            topChild,
            CreateChild("İkinci", 300),
            CreateChild("Üçüncü", 100),
        };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetChildRankAsync(topChild.Id);

        // Assert
        result!.Rank.Should().Be(1);
    }

    // Test 7: Var olmayan çocuk için null dönmeli
    [Fact]
    public async Task GetChildRank_WhenChildNotFound_ShouldReturnNull()
    {
        // Arrange
        var children = new List<ChildProfile> { CreateChild("Ali", 100) };
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetChildRankAsync(Guid.NewGuid());

        // Assert
        result.Should().BeNull();
    }

    // Test 8: GetGlobalLeaderboard varsayılan Top 50 döndürmeli
    [Fact]
    public async Task GetGlobalLeaderboard_ShouldReturnTop50ByDefault()
    {
        // Arrange - 60 çocuk oluştur
        var children = Enumerable.Range(1, 60)
            .Select(i => CreateChild($"Çocuk {i}", i * 10))
            .ToList();
        var progress = BuildProgressMap(children);
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(children);
        _mockProgressRepository.Setup(x => x.GetAllProgressAsync(default)).ReturnsAsync(progress);

        // Act
        var result = await _leaderboardService.GetGlobalLeaderboardAsync();

        // Assert
        result.Should().HaveCount(50);
        result[0].TotalScore.Should().Be(600); // En yüksek score (60 * 10)
        result[0].Rank.Should().Be(1);
    }

    [Fact]
    public async Task GetTopN_AdultAudience_UsesAdultPointsAndExcludesChildren()
    {
        var child = CreateChild("Çocuk", 900);
        var adultLow = CreateChild("Yetişkin A", 10);
        adultLow.GradeLevel = GradeLevel.Adult;
        adultLow.AdultCompetitionPoints = 120;
        adultLow.AdultCompetitionWins = 2;
        adultLow.AdultCompetitionGamesPlayed = 3;
        var adultHigh = CreateChild("Yetişkin B", 5);
        adultHigh.GradeLevel = GradeLevel.Adult;
        adultHigh.AdultCompetitionPoints = 300;
        adultHigh.AdultCompetitionWins = 4;
        adultHigh.AdultCompetitionGamesPlayed = 5;
        var profiles = new List<ChildProfile> { child, adultLow, adultHigh };

        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(profiles);
        _mockProgressRepository
            .Setup(x => x.GetAllProgressAsync(default))
            .ReturnsAsync(BuildProgressMap(profiles));

        var result = await _leaderboardService.GetTopNAsync(
            10,
            CompetitionAudience.Adult);

        result.Should().HaveCount(2);
        result.Select(entry => entry.ChildName).Should().Equal("Yetişkin B", "Yetişkin A");
        result.Should().OnlyContain(entry => entry.ProfileType == "Adult");
        result[0].TotalScore.Should().Be(300);
        result[0].Wins.Should().Be(4);
    }

    [Fact]
    public async Task GetChildRank_AdultProfile_RanksOnlyAgainstAdults()
    {
        var child = CreateChild("Çocuk", 1000);
        var adult = CreateChild("Yetişkin", 0);
        adult.GradeLevel = GradeLevel.Adult;
        adult.AdultCompetitionPoints = 40;
        adult.AdultCompetitionGamesPlayed = 1;

        var profiles = new List<ChildProfile> { child, adult };
        _mockChildProfileRepository.Setup(x => x.GetAllAsync(default)).ReturnsAsync(profiles);
        _mockProgressRepository
            .Setup(x => x.GetAllProgressAsync(default))
            .ReturnsAsync(BuildProgressMap(profiles));

        var result = await _leaderboardService.GetChildRankAsync(adult.Id);

        result.Should().NotBeNull();
        result!.Rank.Should().Be(1);
        result.ProfileType.Should().Be("Adult");
        result.TotalScore.Should().Be(40);
    }
}
