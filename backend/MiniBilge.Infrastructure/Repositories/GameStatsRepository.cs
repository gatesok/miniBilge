using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class GameStatsRepository : IGameStatsRepository
{
    private readonly ApplicationDbContext _context;

    public GameStatsRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<GameStatSnapshot> ApplyResultAsync(
        Guid childProfileId,
        string gameType,
        string categoryKey,
        GameOutcome outcome,
        bool perfectWin,
        int successPercentage)
    {
        categoryKey ??= string.Empty;
        var now = DateTime.UtcNow;

        // Aggregate satırı (CategoryKey == "") — toplam sayaçlar ve seri burada tutulur.
        var aggregate = await GetOrCreateAsync(childProfileId, gameType, string.Empty, now);
        Apply(aggregate, outcome, perfectWin, successPercentage, now, updateStreak: true);

        // Kategori satırı — yalnızca kategori verildiğinde; seri güncellenmez.
        if (!string.IsNullOrEmpty(categoryKey))
        {
            var categoryRow = await GetOrCreateAsync(childProfileId, gameType, categoryKey, now);
            Apply(categoryRow, outcome, perfectWin, successPercentage, now, updateStreak: false);
        }

        await _context.SaveChangesAsync();

        var distinctCategoriesWon = await _context.ProfileGameStats
            .Where(s => s.ChildProfileId == childProfileId
                        && s.GameType == gameType
                        && s.CategoryKey != string.Empty
                        && s.Won > 0)
            .CountAsync();

        var categorySnapshot = string.IsNullOrEmpty(categoryKey)
            ? null
            : await _context.ProfileGameStats.FirstOrDefaultAsync(s =>
                s.ChildProfileId == childProfileId
                && s.GameType == gameType
                && s.CategoryKey == categoryKey);

        return new GameStatSnapshot
        {
            TotalPlayed = aggregate.Played,
            TotalWon = aggregate.Won,
            TotalPerfectWins = aggregate.PerfectWins,
            CurrentWinStreak = aggregate.CurrentWinStreak,
            BestWinStreak = aggregate.BestWinStreak,
            DistinctCategoriesWon = distinctCategoriesWon,
            AverageSuccessPercentage = aggregate.Played > 0
                ? (double)aggregate.SuccessPercentageSum / aggregate.Played
                : 0,
            CategoryPlayed = categorySnapshot?.Played ?? 0,
            CategoryWon = categorySnapshot?.Won ?? 0,
            CategoryAverageSuccessPercentage = categorySnapshot is { Played: > 0 }
                ? (double)categorySnapshot.SuccessPercentageSum / categorySnapshot.Played
                : 0,
        };
    }

    private async Task<ProfileGameStat> GetOrCreateAsync(
        Guid childProfileId, string gameType, string categoryKey, DateTime now)
    {
        var row = await _context.ProfileGameStats.FirstOrDefaultAsync(s =>
            s.ChildProfileId == childProfileId
            && s.GameType == gameType
            && s.CategoryKey == categoryKey);

        if (row == null)
        {
            row = new ProfileGameStat
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                GameType = gameType,
                CategoryKey = categoryKey,
                CreatedAt = now,
            };
            _context.ProfileGameStats.Add(row);
        }

        return row;
    }

    private static void Apply(
        ProfileGameStat row,
        GameOutcome outcome,
        bool perfectWin,
        int successPercentage,
        DateTime now,
        bool updateStreak)
    {
        row.Played++;
        row.SuccessPercentageSum += Math.Clamp(successPercentage, 0, 100);
        row.LastResultAt = now;
        row.UpdatedAt = now;

        switch (outcome)
        {
            case GameOutcome.Win:
                row.Won++;
                if (perfectWin) row.PerfectWins++;
                if (updateStreak)
                {
                    row.CurrentWinStreak++;
                    if (row.CurrentWinStreak > row.BestWinStreak)
                        row.BestWinStreak = row.CurrentWinStreak;
                }
                break;
            case GameOutcome.Loss:
                row.Lost++;
                if (updateStreak) row.CurrentWinStreak = 0;
                break;
            case GameOutcome.Tie:
                row.Tie++;
                if (updateStreak) row.CurrentWinStreak = 0;
                break;
        }
    }
}
