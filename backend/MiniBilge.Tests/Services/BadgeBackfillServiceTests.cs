using FluentAssertions;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class BadgeBackfillServiceTests
{
    // Olay sırası gerektiren, backfill'e dahil edilmemesi gereken rozetler.
    private static readonly string[] EventOrderBadges =
    {
        "challenge_streak_5", "challenge_perfect_win",
        "live_perfect_win", "live_comeback", "fun_perfect",
    };

    private static (BadgeBackfillService service, List<(Guid child, string key)> awarded, Mock<IBadgeRepository> badgeRepo)
        CreateService(
            IReadOnlyList<Guid> profileIds,
            Dictionary<(string gameType, string categoryKey), GameStatSnapshot> stats,
            Func<Guid, string, bool>? hasEarned = null,
            Func<string, bool>? inCatalog = null)
    {
        var childRepo = new Mock<IChildProfileRepository>();
        childRepo.Setup(r => r.GetAllAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(profileIds.Select(id => new ChildProfile { Id = id }).ToList());

        var statsRepo = new Mock<IGameStatsRepository>();
        statsRepo.Setup(r => r.GetSnapshotAsync(It.IsAny<Guid>(), It.IsAny<string>(), It.IsAny<string>()))
            .ReturnsAsync((Guid _, string gt, string ck) =>
                stats.TryGetValue((gt, ck), out var s) ? s : new GameStatSnapshot());

        var badgeRepo = new Mock<IBadgeRepository>();
        badgeRepo.Setup(r => r.HasEarnedAsync(It.IsAny<Guid>(), It.IsAny<string>()))
            .ReturnsAsync((Guid childId, string key) => hasEarned?.Invoke(childId, key) ?? false);

        // AwardAsync yalnızca badgeId alır; key eşlemesi için GetByKeyAsync sonuçlarını izleriz.
        var idToKey = new Dictionary<Guid, string>();
        badgeRepo.Setup(r => r.GetByKeyAsync(It.IsAny<string>()))
            .ReturnsAsync((string key) =>
            {
                if (!(inCatalog?.Invoke(key) ?? true)) return null;
                var badge = new Badge { Id = Guid.NewGuid(), Key = key, IsActive = true };
                idToKey[badge.Id] = key;
                return badge;
            });

        var awarded = new List<(Guid, string)>();
        badgeRepo.Setup(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()))
            .Callback((Guid childId, Guid badgeId) => awarded.Add((childId, idToKey[badgeId])))
            .Returns(Task.CompletedTask);

        var logger = new Mock<ILogger<BadgeBackfillService>>();
        var service = new BadgeBackfillService(childRepo.Object, statsRepo.Object, badgeRepo.Object, logger.Object);
        return (service, awarded, badgeRepo);
    }

    // Tüm backfill rozetlerini hak eden dolu istatistikler (olay sırası alanları da dolu).
    private static Dictionary<(string, string), GameStatSnapshot> FullyQualifiedStats() => new()
    {
        [("challenge", "")] = new GameStatSnapshot
        {
            TotalWon = 50, DistinctCategoriesWon = 3,
            TotalPerfectWins = 5, BestWinStreak = 10, // backfill'e dahil edilmemeli
        },
        [("live_match", "")] = new GameStatSnapshot
        {
            TotalPlayed = 10, TotalWon = 10, DistinctCategoriesWon = 3,
            TotalPerfectWins = 5,
        },
        [("fun", "")] = new GameStatSnapshot
        {
            TotalPlayed = 50, DistinctCategoriesWon = 5, TotalPerfectWins = 5,
        },
        [("fun", "genel_kultur")] = new GameStatSnapshot
        {
            CategoryPlayed = 10, CategoryAverageSuccessPercentage = 80,
        },
        [("fun", "kelime")] = new GameStatSnapshot { CategoryPlayed = 10 },
    };

    private static readonly string[] AllBackfillBadges =
    {
        "challenge_first_win", "challenge_wins_10", "challenge_wins_50", "challenge_variety",
        "live_matches_10", "live_wins_10", "live_variety",
        "fun_first_quiz", "fun_quizzes_10", "fun_quizzes_50", "fun_categories_5",
        "general_culture_master", "word_game_master",
    };

    [Fact]
    public async Task ReportMode_DoesNotAward_ButCountsEligible()
    {
        var child = Guid.NewGuid();
        var (service, awarded, badgeRepo) = CreateService(new[] { child }, FullyQualifiedStats());

        var report = await service.RunAsync(apply: false);

        report.Applied.Should().BeFalse();
        report.ProfilesScanned.Should().Be(1);
        report.TotalAwarded.Should().Be(AllBackfillBadges.Length);
        report.Badges.Select(b => b.BadgeKey).Should().BeEquivalentTo(AllBackfillBadges);
        awarded.Should().BeEmpty();
        badgeRepo.Verify(r => r.AwardAsync(It.IsAny<Guid>(), It.IsAny<Guid>()), Times.Never);
    }

    [Fact]
    public async Task ApplyMode_AwardsEachQualifiedBadge()
    {
        var child = Guid.NewGuid();
        var (service, awarded, _) = CreateService(new[] { child }, FullyQualifiedStats());

        var report = await service.RunAsync(apply: true);

        report.Applied.Should().BeTrue();
        report.TotalAwarded.Should().Be(AllBackfillBadges.Length);
        awarded.Select(a => a.key).Should().BeEquivalentTo(AllBackfillBadges);
        awarded.Should().OnlyContain(a => a.child == child);
    }

    [Fact]
    public async Task DoesNotBackfill_EventOrderBadges()
    {
        var child = Guid.NewGuid();
        var (service, awarded, _) = CreateService(new[] { child }, FullyQualifiedStats());

        await service.RunAsync(apply: true);

        awarded.Select(a => a.key).Should().NotIntersectWith(EventOrderBadges);
    }

    [Fact]
    public async Task AlreadyEarned_IsNotRecounted()
    {
        var child = Guid.NewGuid();
        var (service, awarded, _) = CreateService(
            new[] { child }, FullyQualifiedStats(),
            hasEarned: (_, key) => key == "challenge_first_win");

        var report = await service.RunAsync(apply: true);

        report.TotalAwarded.Should().Be(AllBackfillBadges.Length - 1);
        awarded.Select(a => a.key).Should().NotContain("challenge_first_win");
    }

    [Fact]
    public async Task BadgeNotInCatalog_IsSkipped()
    {
        var child = Guid.NewGuid();
        var (service, awarded, _) = CreateService(
            new[] { child }, FullyQualifiedStats(),
            inCatalog: key => key != "word_game_master");

        var report = await service.RunAsync(apply: true);

        report.TotalAwarded.Should().Be(AllBackfillBadges.Length - 1);
        awarded.Select(a => a.key).Should().NotContain("word_game_master");
    }

    [Theory]
    [InlineData(1, true, false, false)]   // challenge_first_win eşiği
    [InlineData(9, true, false, false)]   // wins_10 eşiği altı
    [InlineData(10, true, true, false)]   // wins_10 tam sınır
    [InlineData(50, true, true, true)]    // wins_50 tam sınır
    public async Task ChallengeWinThresholds_AreRespected(int totalWon, bool first, bool wins10, bool wins50)
    {
        var child = Guid.NewGuid();
        var stats = new Dictionary<(string, string), GameStatSnapshot>
        {
            [("challenge", "")] = new GameStatSnapshot { TotalWon = totalWon },
        };
        var (service, awarded, _) = CreateService(new[] { child }, stats);

        await service.RunAsync(apply: true);
        var keys = awarded.Select(a => a.key).ToList();

        keys.Contains("challenge_first_win").Should().Be(first);
        keys.Contains("challenge_wins_10").Should().Be(wins10);
        keys.Contains("challenge_wins_50").Should().Be(wins50);
    }

    [Theory]
    [InlineData(10, 79, false)]  // ortalama eşiği altı
    [InlineData(10, 80, true)]   // tam sınır
    [InlineData(9, 90, false)]   // oynanan eşiği altı
    public async Task GeneralCultureMaster_RequiresPlayedAndAverage(int played, double avg, bool expected)
    {
        var child = Guid.NewGuid();
        var stats = new Dictionary<(string, string), GameStatSnapshot>
        {
            [("fun", "genel_kultur")] = new GameStatSnapshot
            {
                CategoryPlayed = played, CategoryAverageSuccessPercentage = avg,
            },
        };
        var (service, awarded, _) = CreateService(new[] { child }, stats);

        await service.RunAsync(apply: true);

        awarded.Select(a => a.key).Contains("general_culture_master").Should().Be(expected);
    }

    [Fact]
    public async Task NoStats_AwardsNothing()
    {
        var child = Guid.NewGuid();
        var (service, awarded, _) = CreateService(
            new[] { child }, new Dictionary<(string, string), GameStatSnapshot>());

        var report = await service.RunAsync(apply: true);

        report.TotalAwarded.Should().Be(0);
        awarded.Should().BeEmpty();
    }

    [Fact]
    public async Task MultipleProfiles_AreAggregatedPerBadge()
    {
        var a = Guid.NewGuid();
        var b = Guid.NewGuid();
        var (service, _, _) = CreateService(new[] { a, b }, FullyQualifiedStats());

        var report = await service.RunAsync(apply: false);

        report.ProfilesScanned.Should().Be(2);
        report.Badges.Should().OnlyContain(x => x.EligibleProfiles == 2);
        report.TotalAwarded.Should().Be(AllBackfillBadges.Length * 2);
    }
}
