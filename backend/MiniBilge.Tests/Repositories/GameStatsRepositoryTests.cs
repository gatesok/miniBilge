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
}
