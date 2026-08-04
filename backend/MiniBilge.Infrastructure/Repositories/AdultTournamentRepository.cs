using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class AdultTournamentRepository : IAdultTournamentRepository
{
    private readonly ApplicationDbContext _context;

    public AdultTournamentRepository(ApplicationDbContext context)
        => _context = context;

    public async Task UpsertAsync(Guid childProfileId, DateOnly weekStart, string categoryKey, int points, bool isWin, int correctCount, int answeredCount)
    {
        var add = Math.Max(0, points);
        var addCorrect = Math.Max(0, correctCount);
        var addAnswered = Math.Max(0, answeredCount);

        var entry = await _context.AdultTournamentEntries.FirstOrDefaultAsync(e =>
            e.ChildProfileId == childProfileId &&
            e.WeekStart == weekStart &&
            e.CategoryKey == categoryKey);

        if (entry == null)
        {
            entry = new AdultTournamentEntry
            {
                Id             = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                WeekStart      = weekStart,
                CategoryKey    = categoryKey,
                Points         = add,
                Wins           = isWin ? 1 : 0,
                GamesPlayed    = 1,
                CorrectCount   = addCorrect,
                AnsweredCount  = addAnswered,
                CreatedAt      = DateTime.UtcNow,
            };
            _context.AdultTournamentEntries.Add(entry);
        }
        else
        {
            entry.Points        += add;
            entry.GamesPlayed   += 1;
            if (isWin) entry.Wins += 1;
            entry.CorrectCount  += addCorrect;
            entry.AnsweredCount += addAnswered;
            entry.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }

    public async Task<AdultTournamentEntry?> GetEntryAsync(Guid childProfileId, DateOnly weekStart, string categoryKey)
        => await _context.AdultTournamentEntries
            .AsNoTracking()
            .FirstOrDefaultAsync(e =>
                e.ChildProfileId == childProfileId &&
                e.WeekStart == weekStart &&
                e.CategoryKey == categoryKey &&
                !e.IsDeleted);

    public async Task<List<AdultTournamentEntry>> GetWeeklyOrderedAsync(DateOnly weekStart, string categoryKey)
    {
        var now = DateTime.UtcNow;
        // Yalnızca aktif premium aboneliği olan kullanıcıların profilleri sıralamada listelenir.
        return await _context.AdultTournamentEntries
            .AsNoTracking()
            .Include(e => e.ChildProfile)
            .Where(e => e.WeekStart == weekStart &&
                        e.CategoryKey == categoryKey &&
                        e.Points > 0 &&
                        !e.IsDeleted &&
                        e.ChildProfile.ParentProfile.User.Subscriptions.Any(s =>
                            !s.IsDeleted &&
                            (s.Status == SubscriptionStatus.Active ||
                             s.Status == SubscriptionStatus.GracePeriod) &&
                            s.ExpiresAt > now))
            .OrderByDescending(e => e.Points)
            .ThenByDescending(e => e.Wins)
            .ToListAsync();
    }
}
