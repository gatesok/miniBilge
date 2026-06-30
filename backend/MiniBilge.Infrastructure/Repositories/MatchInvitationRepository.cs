using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class MatchInvitationRepository : IMatchInvitationRepository
{
    private readonly ApplicationDbContext _context;
    private const int InvitationTtlSeconds = 300;

    public MatchInvitationRepository(ApplicationDbContext context)
        => _context = context;

    public async Task<MatchInvitation> CreateAsync(Guid inviterId, Guid inviteeId, Guid? subjectId)
    {
        var invitation = new MatchInvitation
        {
            InviterId  = inviterId,
            InviteeId  = inviteeId,
            SubjectId  = subjectId,
            Status     = MatchInvitationStatus.Pending,
            ExpiresAt  = DateTime.UtcNow.AddSeconds(InvitationTtlSeconds),
            CreatedAt  = DateTime.UtcNow,
        };
        _context.MatchInvitations.Add(invitation);
        await _context.SaveChangesAsync();
        return invitation;
    }

    public async Task<MatchInvitation?> GetByIdAsync(Guid id)
        => await _context.MatchInvitations
            .Include(i => i.Inviter)
            .Include(i => i.Invitee)
            .FirstOrDefaultAsync(i => i.Id == id && !i.IsDeleted);

    public async Task<List<MatchInvitation>> GetPendingForInviteeAsync(Guid inviteeId)
        => await _context.MatchInvitations
            .Include(i => i.Inviter)
            .Where(i =>
                !i.IsDeleted &&
                i.InviteeId == inviteeId &&
                i.Status == MatchInvitationStatus.Pending &&
                i.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(i => i.CreatedAt)
            .ToListAsync();

    public async Task UpdateStatusAsync(Guid id, MatchInvitationStatus status, Guid? matchSessionId = null)
    {
        var inv = await _context.MatchInvitations.FindAsync(id);
        if (inv == null) return;
        inv.Status        = status;
        inv.UpdatedAt     = DateTime.UtcNow;
        if (matchSessionId.HasValue)
            inv.MatchSessionId = matchSessionId.Value;
        await _context.SaveChangesAsync();
    }

    public async Task ExpireOldAsync()
    {
        var expired = await _context.MatchInvitations
            .Where(i =>
                !i.IsDeleted &&
                i.Status == MatchInvitationStatus.Pending &&
                i.ExpiresAt <= DateTime.UtcNow)
            .ToListAsync();

        foreach (var inv in expired)
        {
            inv.Status    = MatchInvitationStatus.Expired;
            inv.UpdatedAt = DateTime.UtcNow;
        }

        if (expired.Any())
            await _context.SaveChangesAsync();
    }

    public async Task<List<MatchInvitation>> GetOtherPendingByInviterAsync(Guid inviterId, Guid excludeInvitationId)
        => await _context.MatchInvitations
            .Where(i =>
                !i.IsDeleted &&
                i.InviterId == inviterId &&
                i.Id != excludeInvitationId &&
                i.Status == MatchInvitationStatus.Pending &&
                i.ExpiresAt > DateTime.UtcNow)
            .ToListAsync();
}
