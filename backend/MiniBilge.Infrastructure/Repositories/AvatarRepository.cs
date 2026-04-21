using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class AvatarRepository : IAvatarRepository
{
    private readonly ApplicationDbContext _context;

    public AvatarRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    // Avatar
    public async Task<Avatar?> GetAvatarByIdAsync(Guid id)
    {
        return await _context.Avatars
            .FirstOrDefaultAsync(a => a.Id == id && !a.IsDeleted);
    }

    public async Task<Avatar?> GetDefaultAvatarAsync()
    {
        return await _context.Avatars
            .FirstOrDefaultAsync(a => a.IsDefault && a.IsActive && !a.IsDeleted);
    }

    public async Task<List<Avatar>> GetAllAvatarsAsync()
    {
        return await _context.Avatars
            .Where(a => a.IsActive && !a.IsDeleted)
            .OrderBy(a => a.Name)
            .ToListAsync();
    }

    // AvatarItem
    public async Task<AvatarItem?> GetItemByIdAsync(Guid id)
    {
        return await _context.AvatarItems
            .FirstOrDefaultAsync(i => i.Id == id && !i.IsDeleted);
    }

    public async Task<List<AvatarItem>> GetAllItemsAsync()
    {
        return await _context.AvatarItems
            .Where(i => !i.IsDeleted)
            .OrderBy(i => i.ItemType)
            .ThenBy(i => i.PointCost)
            .ToListAsync();
    }

    public async Task<List<AvatarItem>> GetActiveItemsAsync()
    {
        return await _context.AvatarItems
            .Where(i => i.IsActive && !i.IsDeleted)
            .OrderBy(i => i.ItemType)
            .ThenBy(i => i.PointCost)
            .ToListAsync();
    }

    // ChildOwnedItem
    public async Task<List<ChildOwnedItem>> GetChildOwnedItemsAsync(Guid childProfileId)
    {
        return await _context.ChildOwnedItems
            .Include(o => o.Item)
            .Where(o => o.ChildProfileId == childProfileId && !o.IsDeleted)
            .OrderByDescending(o => o.PurchasedAt)
            .ToListAsync();
    }

    public async Task<bool> IsItemOwnedAsync(Guid childProfileId, Guid itemId)
    {
        return await _context.ChildOwnedItems
            .AnyAsync(o => o.ChildProfileId == childProfileId && o.ItemId == itemId && !o.IsDeleted);
    }

    public async Task<ChildOwnedItem> AddOwnedItemAsync(ChildOwnedItem ownedItem)
    {
        _context.ChildOwnedItems.Add(ownedItem);
        await _context.SaveChangesAsync();
        return ownedItem;
    }

    // ChildEquippedItem
    public async Task<List<ChildEquippedItem>> GetChildEquippedItemsAsync(Guid childProfileId)
    {
        return await _context.ChildEquippedItems
            .Include(e => e.Item)
            .Where(e => e.ChildProfileId == childProfileId && !e.IsDeleted)
            .OrderBy(e => e.Item.ItemType)
            .ToListAsync();
    }

    public async Task<ChildEquippedItem?> GetEquippedItemByTypeAsync(Guid childProfileId, int itemType)
    {
        return await _context.ChildEquippedItems
            .Include(e => e.Item)
            .FirstOrDefaultAsync(e => e.ChildProfileId == childProfileId 
                && e.Item.ItemType == (MiniBilge.Domain.Enums.ItemType)itemType 
                && !e.IsDeleted);
    }

    public async Task<ChildEquippedItem> EquipItemAsync(ChildEquippedItem equippedItem)
    {
        _context.ChildEquippedItems.Add(equippedItem);
        await _context.SaveChangesAsync();
        return equippedItem;
    }

    public async Task UnequipItemAsync(Guid childProfileId, Guid itemId)
    {
        var equippedItem = await _context.ChildEquippedItems
            .FirstOrDefaultAsync(e => e.ChildProfileId == childProfileId && e.ItemId == itemId && !e.IsDeleted);

        if (equippedItem != null)
        {
            equippedItem.IsDeleted = true;
            equippedItem.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }

    public async Task UnequipItemByTypeAsync(Guid childProfileId, int itemType)
    {
        var equippedItem = await GetEquippedItemByTypeAsync(childProfileId, itemType);

        if (equippedItem != null)
        {
            equippedItem.IsDeleted = true;
            equippedItem.UpdatedAt = DateTime.UtcNow;
            await _context.SaveChangesAsync();
        }
    }
}
