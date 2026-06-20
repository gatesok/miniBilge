using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class BadgeRepository : IBadgeRepository
{
    private readonly ApplicationDbContext _context;

    public BadgeRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Badge>> GetAllAsync()
        => await _context.Badges
            .Where(b => b.IsActive && !b.IsDeleted)
            .OrderBy(b => b.Category)
            .ThenBy(b => b.Rarity)
            .ToListAsync();

    public async Task<Badge?> GetByKeyAsync(string key)
        => await _context.Badges.FirstOrDefaultAsync(b => b.Key == key && b.IsActive && !b.IsDeleted);

    public async Task<List<ChildBadge>> GetEarnedByChildAsync(Guid childProfileId)
        => await _context.ChildBadges
            .Include(cb => cb.Badge)
            .Where(cb => cb.ChildProfileId == childProfileId)
            .OrderByDescending(cb => cb.EarnedAt)
            .ToListAsync();

    public async Task<bool> HasEarnedAsync(Guid childProfileId, string badgeKey)
        => await _context.ChildBadges
            .AnyAsync(cb => cb.ChildProfileId == childProfileId && cb.Badge.Key == badgeKey);

    public async Task AwardAsync(Guid childProfileId, Guid badgeId)
    {
        var already = await _context.ChildBadges
            .AnyAsync(cb => cb.ChildProfileId == childProfileId && cb.BadgeId == badgeId);
        if (already) return;

        await _context.ChildBadges.AddAsync(new ChildBadge
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            BadgeId = badgeId,
            EarnedAt = DateTime.UtcNow,
        });
        await _context.SaveChangesAsync();
    }
}
