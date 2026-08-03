using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Repositories;
using Xunit;

namespace MiniBilge.Tests.Repositories;

public class GameStatsRepositoryTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly GameStatsRepository _repository;

    public GameStatsRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _repository = new GameStatsRepository(_context);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    [Fact]
    public async Task ApplyResultAsync_ShouldIncrementCounters()
    {
        var childId = Guid.NewGuid();

        var snapshot = await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: true, successPercentage: 100);

        snapshot.TotalPlayed.Should().Be(1);
        snapshot.CategoryPlayed.Should().Be(1);
        snapshot.DistinctCategoriesWon.Should().Be(1);
    }

    [Fact]
    public async Task ApplyResultAsync_SameIdempotencyKey_ShouldNotDoubleCount()
    {
        var childId = Guid.NewGuid();
        const string key = "ent_123456";

        var first = await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: true, successPercentage: 100,
            idempotencyKey: key);

        var second = await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: true, successPercentage: 100,
            idempotencyKey: key);

        first.TotalPlayed.Should().Be(1);
        second.TotalPlayed.Should().Be(1);
        second.CategoryPlayed.Should().Be(1);
    }

    [Fact]
    public async Task ApplyResultAsync_DifferentIdempotencyKeys_ShouldCountBoth()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: true, successPercentage: 100,
            idempotencyKey: "ent_1");

        var second = await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: true, successPercentage: 100,
            idempotencyKey: "ent_2");

        second.TotalPlayed.Should().Be(2);
    }

    // ── Aile izolasyonu: bir oyun türünün sonucu başka aileyi etkilemez ──

    [Fact]
    public async Task ApplyResultAsync_ChallengeWin_DoesNotAffectLiveOrFun()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "challenge", "matematik", GameOutcome.Win, perfectWin: true, successPercentage: 100);

        var live = await _repository.GetSnapshotAsync(childId, "live_match");
        var fun = await _repository.GetSnapshotAsync(childId, "fun");

        live.TotalPlayed.Should().Be(0);
        live.TotalWon.Should().Be(0);
        fun.TotalPlayed.Should().Be(0);
        fun.TotalWon.Should().Be(0);
    }

    [Fact]
    public async Task ApplyResultAsync_LiveWin_DoesNotAffectChallengeOrFun()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "live_match", "matematik", GameOutcome.Win, perfectWin: false, successPercentage: 90);

        var challenge = await _repository.GetSnapshotAsync(childId, "challenge");
        var fun = await _repository.GetSnapshotAsync(childId, "fun");

        challenge.TotalPlayed.Should().Be(0);
        fun.TotalPlayed.Should().Be(0);
    }

    // ── Kategori çeşitliliği ─────────────────────────────────────────────

    [Fact]
    public async Task DistinctCategoriesWon_SameCategoryReplayed_DoesNotIncrease()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: false, successPercentage: 80);
        await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: false, successPercentage: 80);
        var snapshot = await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: false, successPercentage: 80);

        snapshot.DistinctCategoriesWon.Should().Be(1);
        snapshot.CategoryPlayed.Should().Be(3);
    }

    [Fact]
    public async Task DistinctCategoriesWon_DifferentCategories_Increases()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "fun", "genel_kultur", GameOutcome.Win, perfectWin: false, successPercentage: 80);
        await _repository.ApplyResultAsync(
            childId, "fun", "muzik", GameOutcome.Win, perfectWin: false, successPercentage: 80);
        var snapshot = await _repository.ApplyResultAsync(
            childId, "fun", "sinema", GameOutcome.Win, perfectWin: false, successPercentage: 80);

        snapshot.DistinctCategoriesWon.Should().Be(3);
    }

    [Fact]
    public async Task DistinctCategoriesWon_CategoryOnlyLost_NotCounted()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "challenge", "matematik", GameOutcome.Loss, perfectWin: false, successPercentage: 40);
        var snapshot = await _repository.GetSnapshotAsync(childId, "challenge");

        snapshot.DistinctCategoriesWon.Should().Be(0);
    }

    // ── Kusursuz galibiyet sayacı ────────────────────────────────────────

    [Fact]
    public async Task PerfectWin_OnlyCountsWhenFlagged()
    {
        var childId = Guid.NewGuid();

        await _repository.ApplyResultAsync(
            childId, "challenge", "matematik", GameOutcome.Win, perfectWin: false, successPercentage: 70);
        var afterNonPerfect = await _repository.GetSnapshotAsync(childId, "challenge");
        afterNonPerfect.TotalPerfectWins.Should().Be(0);

        await _repository.ApplyResultAsync(
            childId, "challenge", "matematik", GameOutcome.Win, perfectWin: true, successPercentage: 100);
        var afterPerfect = await _repository.GetSnapshotAsync(childId, "challenge");
        afterPerfect.TotalPerfectWins.Should().Be(1);
    }
}
