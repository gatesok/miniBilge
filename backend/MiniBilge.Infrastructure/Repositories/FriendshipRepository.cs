using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class FriendshipRepository : IFriendshipRepository
{
    private readonly ApplicationDbContext _context;

    public FriendshipRepository(ApplicationDbContext context)
        => _context = context;

    public async Task<Friendship> CreateAsync(Guid requesterId, Guid addresseeId)
    {
        var friendship = new Friendship
        {
            RequesterId = requesterId,
            AddresseeId = addresseeId,
            Status      = FriendshipStatus.Pending,
            CreatedAt   = DateTime.UtcNow,
        };
        _context.Friendships.Add(friendship);
        await _context.SaveChangesAsync();
        return friendship;
    }

    public async Task<Friendship?> GetByIdAsync(Guid id)
        => await _context.Friendships
            .Include(f => f.Requester)
            .Include(f => f.Addressee)
            .FirstOrDefaultAsync(f => f.Id == id && !f.IsDeleted);

    public async Task<Friendship?> GetBetweenAsync(Guid childA, Guid childB)
        => await _context.Friendships
            .FirstOrDefaultAsync(f =>
                (f.RequesterId == childA && f.AddresseeId == childB) ||
                (f.RequesterId == childB && f.AddresseeId == childA));

    public async Task<List<Friendship>> GetAcceptedFriendsAsync(Guid childId)
        => await _context.Friendships
            .Include(f => f.Requester)
            .Include(f => f.Addressee)
            .Where(f =>
                !f.IsDeleted &&
                f.Status == FriendshipStatus.Accepted &&
                (f.RequesterId == childId || f.AddresseeId == childId))
            .ToListAsync();

    public async Task<List<Friendship>> GetPendingRequestsAsync(Guid addresseeId)
        => await _context.Friendships
            .Include(f => f.Requester)
            .Where(f =>
                !f.IsDeleted &&
                f.AddresseeId == addresseeId &&
                f.Status == FriendshipStatus.Pending)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

    public async Task UpdateStatusAsync(Guid id, FriendshipStatus status)
    {
        var f = await _context.Friendships.FindAsync(id);
        if (f == null) return;
        f.Status    = status;
        f.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Guid id)
    {
        var f = await _context.Friendships.FindAsync(id);
        if (f == null) return;
        f.IsDeleted = true;
        f.UpdatedAt = DateTime.UtcNow;
        await _context.SaveChangesAsync();
    }

    public Task SaveAsync() => _context.SaveChangesAsync();
}
