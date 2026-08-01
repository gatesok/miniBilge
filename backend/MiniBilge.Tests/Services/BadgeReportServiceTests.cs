using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

public class BadgeReportServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly BadgeReportService _service;

    public BadgeReportServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _service = new BadgeReportService(_context);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private Badge SeedBadge(string key, string category, string rarity = "bronze",
        bool isActive = true, bool isDeleted = false)
    {
        var badge = new Badge
        {
            Id = Guid.NewGuid(),
            Key = key,
            Name = key,
            Category = category,
            Rarity = rarity,
            IsActive = isActive,
            IsDeleted = isDeleted,
        };
        _context.Badges.Add(badge);
        return badge;
    }

    private ChildProfile SeedProfile(bool adult, bool isDeleted = false)
    {
        var profile = new ChildProfile
        {
            Id = Guid.NewGuid(),
            Name = "p",
            GradeLevel = adult ? GradeLevel.Adult : GradeLevel.Grade3,
            IsDeleted = isDeleted,
        };
        _context.ChildProfiles.Add(profile);
        return profile;
    }

    private void SeedEarned(ChildProfile profile, Badge badge)
    {
        _context.ChildBadges.Add(new ChildBadge
        {
            Id = Guid.NewGuid(),
            ChildProfileId = profile.Id,
            BadgeId = badge.Id,
            EarnedAt = DateTime.UtcNow,
        });
    }

    [Fact]
    public async Task CountsProfiles_WithChildAdultSplit()
    {
        SeedProfile(adult: false);
        SeedProfile(adult: false);
        SeedProfile(adult: true);
        SeedProfile(adult: true, isDeleted: true); // silinmiş sayılmaz
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();

        report.TotalProfiles.Should().Be(3);
        report.ChildProfiles.Should().Be(2);
        report.AdultProfiles.Should().Be(1);
    }

    [Fact]
    public async Task PerBadge_ReportsEarnedCountAndChildAdultSplit()
    {
        var child1 = SeedProfile(adult: false);
        var child2 = SeedProfile(adult: false);
        var adult1 = SeedProfile(adult: true);
        var badge = SeedBadge("challenge_first_win", "challenge");
        SeedEarned(child1, badge);
        SeedEarned(adult1, badge);
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();
        var stat = report.Badges.Single(b => b.Key == "challenge_first_win");

        stat.EarnedCount.Should().Be(2);
        stat.ChildEarned.Should().Be(1);
        stat.AdultEarned.Should().Be(1);
        stat.EarnRate.Should().BeApproximately(2.0 / 3.0, 0.001);
        _ = child2; // kazanmadı → sayılmaz
    }

    [Fact]
    public async Task DuplicateChildBadge_CountedOnce()
    {
        var child = SeedProfile(adult: false);
        var badge = SeedBadge("fun_first_quiz", "fun");
        SeedEarned(child, badge);
        SeedEarned(child, badge); // mükerrer satır
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();

        report.Badges.Single(b => b.Key == "fun_first_quiz").EarnedCount.Should().Be(1);
    }

    [Fact]
    public async Task GameType_ReportsRatePerCategory()
    {
        var c1 = SeedProfile(adult: false);
        var c2 = SeedProfile(adult: false);
        var challengeA = SeedBadge("challenge_first_win", "challenge");
        var challengeB = SeedBadge("challenge_wins_10", "challenge");
        SeedBadge("fun_first_quiz", "fun");
        SeedEarned(c1, challengeA);
        SeedEarned(c1, challengeB);
        SeedEarned(c2, challengeA);
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();
        var challenge = report.GameTypes.Single(g => g.Category == "challenge");
        var fun = report.GameTypes.Single(g => g.Category == "fun");

        challenge.BadgeCount.Should().Be(2);
        challenge.TotalEarned.Should().Be(3);       // c1×2 + c2×1
        challenge.ProfilesWithAny.Should().Be(2);    // c1, c2
        challenge.EarnRate.Should().BeApproximately(1.0, 0.001);
        fun.ProfilesWithAny.Should().Be(0);
        fun.EarnRate.Should().Be(0);
    }

    [Fact]
    public async Task NeverEarned_ProducesWarning()
    {
        SeedProfile(adult: false);
        SeedBadge("live_comeback", "live_match");
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();

        report.Warnings.NeverEarned.Should().Contain("live_comeback");
        report.Warnings.TooEasy.Should().BeEmpty();
    }

    [Fact]
    public async Task TooEasy_ProducesWarning_WhenRateAtOrAboveThreshold()
    {
        var c1 = SeedProfile(adult: false);
        var c2 = SeedProfile(adult: false);
        var easy = SeedBadge("fun_first_quiz", "fun");
        var hard = SeedBadge("fun_quizzes_50", "fun");
        SeedEarned(c1, easy);
        SeedEarned(c2, easy);   // %100 → aşırı kolay
        SeedEarned(c1, hard);   // %50
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync(tooEasyThreshold: 0.8);

        report.Warnings.TooEasy.Should().Contain("fun_first_quiz");
        report.Warnings.TooEasy.Should().NotContain("fun_quizzes_50");
        report.Warnings.TooEasyThreshold.Should().Be(0.8);
    }

    [Fact]
    public async Task InactiveOrDeletedBadge_IsExcluded()
    {
        var child = SeedProfile(adult: false);
        var inactive = SeedBadge("old_inactive", "special", isActive: false);
        var deleted = SeedBadge("old_deleted", "special", isDeleted: true);
        SeedEarned(child, inactive);
        SeedEarned(child, deleted);
        await _context.SaveChangesAsync();

        var report = await _service.GetReportAsync();

        report.Badges.Should().NotContain(b => b.Key == "old_inactive" || b.Key == "old_deleted");
    }

    [Fact]
    public async Task EmptyDatabase_ReturnsZeros_WithoutDivideByZero()
    {
        var report = await _service.GetReportAsync();

        report.TotalProfiles.Should().Be(0);
        report.Badges.Should().BeEmpty();
        report.GameTypes.Should().BeEmpty();
        report.Warnings.TooEasy.Should().BeEmpty();
    }
}
