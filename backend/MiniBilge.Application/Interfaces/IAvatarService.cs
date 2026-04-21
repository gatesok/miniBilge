using MiniBilge.Application.DTOs.Avatar;

namespace MiniBilge.Application.Interfaces;

public interface IAvatarService
{
    // Item management
    Task<List<AvatarItemDto>> GetAvailableItemsAsync(Guid childProfileId);
    Task<AvatarItemDto?> GetItemByIdAsync(Guid itemId);
    
    // Purchase
    Task<PurchaseItemResponse> PurchaseItemAsync(Guid childProfileId, Guid itemId);
    
    // Equip/Unequip
    Task<bool> EquipItemAsync(Guid childProfileId, Guid itemId);
    Task<bool> UnequipItemAsync(Guid childProfileId, Guid itemId);
    
    // Avatar info
    Task<ChildAvatarDto> GetChildAvatarAsync(Guid childProfileId);
    Task<List<AvatarItemDto>> GetOwnedItemsAsync(Guid childProfileId);
    Task<List<EquippedItemDto>> GetEquippedItemsAsync(Guid childProfileId);
}
