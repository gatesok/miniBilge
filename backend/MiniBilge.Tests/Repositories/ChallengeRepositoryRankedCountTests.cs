using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Repositories;
using Xunit;

namespace MiniBilge.Tests.Repositories;

// §5 Rekabet adaleti: sıralama puanı uygunluğu için "bugün tamamlanan yetişkin
// yarışma" sayımı. Günün ilk 3 oyunu ve aynı rakibe karşı ilk oyun uygundur.
public class ChallengeRepositoryRankedCountTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly ChallengeRepository _repository;
    private readonly DateTime _dayStartUtc = DateTime.UtcNow.Date;

    public ChallengeRepositoryRankedCountTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _repository = new ChallengeRepository(_context);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private Challenge Seed(
        Guid challengerId,
        Guid challengeeId,
        DateTime doneAt,
        ChallengeStatus status = ChallengeStatus.Completed,
        AdultCompetitionType? type = AdultCompetitionType.EntertainmentQuiz)
    {
        var challenge = new Challenge
        {
            Id = Guid.NewGuid(),
            ChallengerId = challengerId,
            ChallengeeId = challengeeId,
            CompetitionType = type,
            Status = status,
            ChallengerScore = 8,
            ChallengeeScore = 6,
            ChallengerDoneAt = doneAt,
            ChallengeeDoneAt = doneAt,
            ExpiresAt = doneAt.AddHours(48),
            CreatedAt = doneAt,
        };
        _context.Challenges.Add(challenge);
        _context.SaveChanges();
        return challenge;
    }

    [Fact]
    public async Task Count_SadeceBugunTamamlananYetiskinOyunlariSayar()
    {
        var me = Guid.NewGuid();
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(1));                 // bugün
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(2));                 // bugün
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddDays(-1));                 // dün → sayılmaz
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(3),
            status: ChallengeStatus.ChallengerDone);                       // tamamlanmadı → sayılmaz
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(4), type: null);    // çocuk oyunu → sayılmaz

        var count = await _repository.CountCompletedAdultCompetitionsTodayAsync(
            me, _dayStartUtc, null, Guid.NewGuid());

        count.Should().Be(2);
    }

    [Fact]
    public async Task Count_MevcutMeydanOkumayiDislar()
    {
        var me = Guid.NewGuid();
        var current = Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(1));
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(2));

        var count = await _repository.CountCompletedAdultCompetitionsTodayAsync(
            me, _dayStartUtc, null, current.Id);

        count.Should().Be(1);
    }

    [Fact]
    public async Task Count_OpponentVerilince_YalnizcaRakipleOynananlariSayar()
    {
        var me = Guid.NewGuid();
        var rakip = Guid.NewGuid();
        Seed(me, rakip, _dayStartUtc.AddHours(1));            // bu rakip
        Seed(rakip, me, _dayStartUtc.AddHours(2));            // bu rakip (yön ters)
        Seed(me, Guid.NewGuid(), _dayStartUtc.AddHours(3));   // başka rakip

        var vsOpponent = await _repository.CountCompletedAdultCompetitionsTodayAsync(
            me, _dayStartUtc, rakip, Guid.NewGuid());

        vsOpponent.Should().Be(2);
    }
}
