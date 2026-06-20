using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class CardRepository : ICardRepository
{
    private readonly ApplicationDbContext _context;

    public CardRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<CollectibleCard>> GetAllActiveAsync()
        => await _context.CollectibleCards
            .Where(c => c.IsActive && !c.IsDeleted)
            .OrderBy(c => c.CardNumber)
            .ToListAsync();

    public async Task<List<ChildCard>> GetCollectionByChildAsync(Guid childProfileId)
        => await _context.ChildCards
            .Include(cc => cc.Card)
            .Where(cc => cc.ChildProfileId == childProfileId)
            .OrderBy(cc => cc.Card.CardNumber)
            .ToListAsync();

    public async Task<ChildCard?> GetChildCardAsync(Guid childProfileId, Guid cardId)
        => await _context.ChildCards
            .FirstOrDefaultAsync(cc => cc.ChildProfileId == childProfileId && cc.CardId == cardId);

    public async Task AddOrIncrementAsync(Guid childProfileId, Guid cardId, string source)
    {
        var existing = await GetChildCardAsync(childProfileId, cardId);
        var now = DateTime.UtcNow;

        if (existing != null)
        {
            existing.Count++;
            existing.LastEarnedAt = now;
        }
        else
        {
            await _context.ChildCards.AddAsync(new ChildCard
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                CardId = cardId,
                Count = 1,
                FirstEarnedAt = now,
                LastEarnedAt = now,
            });
        }

        await _context.CardDropLogs.AddAsync(new CardDropLog
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            CardId = cardId,
            Source = source,
            EarnedAt = now,
        });

        await _context.SaveChangesAsync();
    }
}
