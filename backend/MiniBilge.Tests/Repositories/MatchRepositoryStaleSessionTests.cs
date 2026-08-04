using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Repositories;
using Xunit;

namespace MiniBilge.Tests.Repositories;

// QA (e): Maç başladıktan sonra bağlantı kopmasında hak iade EDİLMEZ.
// Rezerve iadesi yalnızca "hiç başlamamış" (Created + StartedAt == null) oturumlar
// için yapılır; başlamış (InProgress ya da StartedAt dolu) oturumlar sorguya dahil olmaz.
public class MatchRepositoryStaleSessionTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly MatchRepository _repository;

    public MatchRepositoryStaleSessionTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _repository = new MatchRepository(_context);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    [Fact]
    public async Task GetStaleCreatedMatchSessions_ExcludesStartedAndInProgressSessions()
    {
        var old = DateTime.UtcNow.AddMinutes(-10);

        // Hiç başlamamış eski oturum → iade adayı.
        var neverStarted = new MatchSession
        {
            Id = Guid.NewGuid(),
            Status = MatchSessionStatus.Created,
            StartedAt = null,
            CreatedAt = old,
        };
        // Başlamış oturum (StartedAt dolu) → hariç.
        var started = new MatchSession
        {
            Id = Guid.NewGuid(),
            Status = MatchSessionStatus.Created,
            StartedAt = old,
            CreatedAt = old,
        };
        // Devam eden maç → hariç.
        var inProgress = new MatchSession
        {
            Id = Guid.NewGuid(),
            Status = MatchSessionStatus.InProgress,
            StartedAt = old,
            CreatedAt = old,
        };

        _context.MatchSessions.AddRange(neverStarted, started, inProgress);
        await _context.SaveChangesAsync();

        // CreatedAt insert sırasında UtcNow ile ezildiği için eski tarihe geri çek.
        neverStarted.CreatedAt = old;
        started.CreatedAt = old;
        inProgress.CreatedAt = old;
        await _context.SaveChangesAsync();

        var result = await _repository.GetStaleCreatedMatchSessionsAsync(DateTime.UtcNow.AddSeconds(-90));

        result.Should().ContainSingle();
        result.Single().Id.Should().Be(neverStarted.Id);
    }
}
