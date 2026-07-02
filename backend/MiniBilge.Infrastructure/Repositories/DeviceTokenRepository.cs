using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class DeviceTokenRepository : IDeviceTokenRepository
{
    private readonly ApplicationDbContext _context;

    public DeviceTokenRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task UpsertAsync(Guid childProfileId, string token, string platform)
    {
        var existing = await _context.DeviceTokens
            .FirstOrDefaultAsync(dt => dt.Token == token);

        if (existing is not null)
        {
            // Update child association if token moved to a different child
            existing.ChildProfileId = childProfileId;
            existing.Platform = platform;
            existing.UpdatedAt = DateTime.UtcNow;
        }
        else
        {
            // Aynı çocuk + platform için önceki tüm tokenleri sil — tek token kalsın.
            // (Token yenilenince eski token hâlâ geçerli olabilir; ikisi de aktif olunca
            // bildirim çift gider.)
            var old = await _context.DeviceTokens
                .Where(dt => dt.ChildProfileId == childProfileId && dt.Platform == platform)
                .ToListAsync();
            _context.DeviceTokens.RemoveRange(old);

            await _context.DeviceTokens.AddAsync(new DeviceToken
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                Token = token,
                Platform = platform,
                CreatedAt = DateTime.UtcNow,
            });
        }

        await _context.SaveChangesAsync();
    }

    public async Task<IEnumerable<string>> GetTokensByChildIdAsync(Guid childProfileId)
    {
        return await _context.DeviceTokens
            .Where(dt => dt.ChildProfileId == childProfileId && !dt.IsDeleted)
            .Select(dt => dt.Token)
            .ToListAsync();
    }

    public async Task<IEnumerable<string>> GetTokensByChildIdsAsync(IEnumerable<Guid> childProfileIds)
    {
        var ids = childProfileIds.ToList();
        return await _context.DeviceTokens
            .Where(dt => ids.Contains(dt.ChildProfileId) && !dt.IsDeleted)
            .Select(dt => dt.Token)
            .ToListAsync();
    }

    public async Task<IEnumerable<(Guid ChildProfileId, string Token)>> GetAllActiveTokensAsync()
    {
        return await _context.DeviceTokens
            .Where(dt => !dt.IsDeleted)
            .Select(dt => new ValueTuple<Guid, string>(dt.ChildProfileId, dt.Token))
            .ToListAsync();
    }
}
