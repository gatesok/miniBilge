using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IAvatarRepository
{
    // Avatar
    Task<Avatar?> GetAvatarByIdAsync(Guid id);
    Task<Avatar?> GetDefaultAvatarAsync();
    Task<List<Avatar>> GetAllAvatarsAsync();
    
    // AvatarItem
    Task<AvatarItem?> GetItemByIdAsync(Guid id);
    Task<List<AvatarItem>> GetAllItemsAsync();
    Task<List<AvatarItem>> GetActiveItemsAsync();
    
    // ChildOwnedItem
    Task<List<ChildOwnedItem>> GetChildOwnedItemsAsync(Guid childProfileId);
    Task<bool> IsItemOwnedAsync(Guid childProfileId, Guid itemId);
    Task<ChildOwnedItem> AddOwnedItemAsync(ChildOwnedItem ownedItem);
    
    // ChildEquippedItem
    Task<List<ChildEquippedItem>> GetChildEquippedItemsAsync(Guid childProfileId);
    Task<ChildEquippedItem?> GetEquippedItemByTypeAsync(Guid childProfileId, int itemType);
    Task<ChildEquippedItem> EquipItemAsync(ChildEquippedItem equippedItem);
    Task UnequipItemAsync(Guid childProfileId, Guid itemId);
    Task UnequipItemByTypeAsync(Guid childProfileId, int itemType);
}
