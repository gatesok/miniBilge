using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class ChildProfileRepository : IChildProfileRepository
{
    private readonly ApplicationDbContext _context;

    public ChildProfileRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<ChildProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await _context.ChildProfiles
            .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted, cancellationToken);
    }

    public async Task<List<ChildProfile>> GetByParentIdAsync(Guid parentId, CancellationToken cancellationToken = default)
    {
        return await _context.ChildProfiles
            .Where(c => c.ParentProfileId == parentId && !c.IsDeleted)
            .OrderBy(c => c.CreatedAt)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<ChildProfile>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await _context.ChildProfiles
            .Where(c => !c.IsDeleted)
            .ToListAsync(cancellationToken);
    }

    public async Task<ChildProfile?> GetByFriendCodeAsync(string friendCode, CancellationToken cancellationToken = default)
    {
        return await _context.ChildProfiles
            .FirstOrDefaultAsync(c => c.FriendCode == friendCode && !c.IsDeleted, cancellationToken);
    }

    public async Task<bool> FriendCodeExistsAsync(string friendCode, CancellationToken cancellationToken = default)
    {
        return await _context.ChildProfiles
            .AnyAsync(c => c.FriendCode == friendCode, cancellationToken);
    }

    public async Task<ChildProfile> CreateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default)
    {
        await _context.ChildProfiles.AddAsync(childProfile, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return childProfile;
    }

    public async Task UpdateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default)
    {
        _context.ChildProfiles.Update(childProfile);
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var childProfile = await GetByIdAsync(id, cancellationToken);
        if (childProfile != null)
        {
            childProfile.IsDeleted = true;
            await UpdateAsync(childProfile, cancellationToken);
        }
    }
}
