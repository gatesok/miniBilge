using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Rozet kazanımlarını yönetim raporuna dönüştürür. Ayrıntılar için
/// <see cref="IBadgeReportService"/>.
/// </summary>
public class BadgeReportService : IBadgeReportService
{
    private readonly ApplicationDbContext _db;

    public BadgeReportService(ApplicationDbContext db)
    {
        _db = db;
    }

    public async Task<BadgeAdminReport> GetReportAsync(
        double tooEasyThreshold = 0.8, CancellationToken cancellationToken = default)
    {
        var profiles = await _db.ChildProfiles
            .Where(p => !p.IsDeleted)
            .Select(p => new { p.Id, IsAdult = p.GradeLevel == GradeLevel.Adult })
            .ToListAsync(cancellationToken);

        var isAdultById = profiles.ToDictionary(p => p.Id, p => p.IsAdult);
        var totalProfiles = profiles.Count;
        var adultProfiles = profiles.Count(p => p.IsAdult);

        var badges = await _db.Badges
            .Where(b => b.IsActive && !b.IsDeleted)
            .OrderBy(b => b.Category).ThenBy(b => b.Rarity)
            .Select(b => new { b.Id, b.Key, b.Name, b.Category, b.Rarity })
            .ToListAsync(cancellationToken);

        var badgeById = badges.ToDictionary(b => b.Id);

        var rawEarned = await _db.ChildBadges
            .Select(cb => new { cb.ChildProfileId, cb.BadgeId })
            .ToListAsync(cancellationToken);

        // Yalnızca aktif rozet + mevcut (silinmemiş) profil eşleşmelerini,
        // (profil, rozet) çifti başına tekilleştirerek al.
        var earned = rawEarned
            .Where(e => badgeById.ContainsKey(e.BadgeId) && isAdultById.ContainsKey(e.ChildProfileId))
            .GroupBy(e => (e.ChildProfileId, e.BadgeId))
            .Select(g => new
            {
                g.Key.ChildProfileId,
                g.Key.BadgeId,
                Category = badgeById[g.Key.BadgeId].Category,
                IsAdult = isAdultById[g.Key.ChildProfileId],
            })
            .ToList();

        var earnedByBadge = earned.GroupBy(e => e.BadgeId)
            .ToDictionary(g => g.Key, g => g.ToList());

        var badgeStats = badges.Select(b =>
        {
            var rows = earnedByBadge.GetValueOrDefault(b.Id) ?? new();
            var earnedCount = rows.Count;
            var adultEarned = rows.Count(r => r.IsAdult);
            return new BadgeStat
            {
                Key = b.Key,
                Name = b.Name,
                Category = b.Category,
                Rarity = b.Rarity,
                EarnedCount = earnedCount,
                ChildEarned = earnedCount - adultEarned,
                AdultEarned = adultEarned,
                EarnRate = totalProfiles > 0 ? (double)earnedCount / totalProfiles : 0,
            };
        }).ToList();

        var gameTypeStats = badges
            .GroupBy(b => b.Category)
            .Select(g =>
            {
                var rows = earned.Where(e => e.Category == g.Key).ToList();
                var profilesWithAny = rows.Select(r => r.ChildProfileId).Distinct().Count();
                return new GameTypeStat
                {
                    Category = g.Key,
                    BadgeCount = g.Count(),
                    TotalEarned = rows.Count,
                    ProfilesWithAny = profilesWithAny,
                    EarnRate = totalProfiles > 0 ? (double)profilesWithAny / totalProfiles : 0,
                };
            })
            .OrderBy(s => s.Category)
            .ToList();

        var warnings = new BadgeReportWarnings
        {
            TooEasyThreshold = tooEasyThreshold,
            NeverEarned = badgeStats.Where(s => s.EarnedCount == 0).Select(s => s.Key).ToList(),
            TooEasy = totalProfiles > 0
                ? badgeStats.Where(s => s.EarnRate >= tooEasyThreshold).Select(s => s.Key).ToList()
                : new(),
        };

        return new BadgeAdminReport
        {
            TotalProfiles = totalProfiles,
            ChildProfiles = totalProfiles - adultProfiles,
            AdultProfiles = adultProfiles,
            Badges = badgeStats,
            GameTypes = gameTypeStats,
            Warnings = warnings,
        };
    }
}
