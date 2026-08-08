using MiniBilge.Application.DTOs.Avatar;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class AvatarService : IAvatarService
{
    private readonly IAvatarRepository _avatarRepository;
    private readonly IChildProfileRepository _childProfileRepository;

    public AvatarService(
        IAvatarRepository avatarRepository,
        IChildProfileRepository childProfileRepository)
    {
        _avatarRepository = avatarRepository;
        _childProfileRepository = childProfileRepository;
    }

    public async Task<List<AvatarItemDto>> GetAvailableItemsAsync(Guid childProfileId)
    {
        var items = await _avatarRepository.GetActiveItemsAsync();
        var ownedItems = await _avatarRepository.GetChildOwnedItemsAsync(childProfileId);
        var equippedItems = await _avatarRepository.GetChildEquippedItemsAsync(childProfileId);

        var ownedItemIds = ownedItems.Select(o => o.ItemId).ToHashSet();
        var equippedItemIds = equippedItems.Select(e => e.ItemId).ToHashSet();

        return items.Select(item => new AvatarItemDto
        {
            Id = item.Id,
            Name = item.Name,
            ItemType = (int)item.ItemType,
            ItemTypeName = item.ItemType.ToString(),
            PointCost = item.PointCost,
            ImageUrl = item.ImageUrl,
            Category = item.Category,
            IsOwned = ownedItemIds.Contains(item.Id),
            IsEquipped = equippedItemIds.Contains(item.Id)
        }).ToList();
    }

    public async Task<AvatarItemDto?> GetItemByIdAsync(Guid itemId)
    {
        var item = await _avatarRepository.GetItemByIdAsync(itemId);
        if (item == null)
            return null;

        return new AvatarItemDto
        {
            Id = item.Id,
            Name = item.Name,
            ItemType = (int)item.ItemType,
            ItemTypeName = item.ItemType.ToString(),
            PointCost = item.PointCost,
            ImageUrl = item.ImageUrl,
            Category = item.Category
        };
    }

    public async Task<PurchaseItemResponse> PurchaseItemAsync(Guid childProfileId, Guid itemId)
    {
        // Get child profile
        var child = await _childProfileRepository.GetByIdAsync(childProfileId);
        if (child == null)
        {
            return new PurchaseItemResponse
            {
                Success = false,
                Message = "Çocuk profili bulunamadı."
            };
        }

        // Get item
        var item = await _avatarRepository.GetItemByIdAsync(itemId);
        if (item == null)
        {
            return new PurchaseItemResponse
            {
                Success = false,
                Message = "Aksesuar bulunamadı."
            };
        }

        // Check if already owned
        var isOwned = await _avatarRepository.IsItemOwnedAsync(childProfileId, itemId);
        if (isOwned)
        {
            return new PurchaseItemResponse
            {
                Success = false,
                Message = "Bu aksesuara zaten sahipsin!"
            };
        }

        // Check points
        if (child.TotalCoins < item.PointCost)
        {
            return new PurchaseItemResponse
            {
                Success = false,
                Message = $"Yetersiz puan! Gerekli: {item.PointCost}, Mevcut: {child.TotalCoins}",
                RemainingPoints = child.TotalCoins
            };
        }

        // Deduct points
        child.TotalCoins -= item.PointCost;
        await _childProfileRepository.UpdateAsync(child);

        // Add to owned items
        var ownedItem = new ChildOwnedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            ItemId = itemId,
            PurchasedAt = DateTime.UtcNow
        };

        await _avatarRepository.AddOwnedItemAsync(ownedItem);

        return new PurchaseItemResponse
        {
            Success = true,
            Message = "Aksesuar başarıyla satın alındı!",
            RemainingPoints = child.TotalCoins,
            PurchasedItem = new AvatarItemDto
            {
                Id = item.Id,
                Name = item.Name,
                ItemType = (int)item.ItemType,
                ItemTypeName = item.ItemType.ToString(),
                PointCost = item.PointCost,
                ImageUrl = item.ImageUrl,
                Category = item.Category,
                IsOwned = true,
                IsEquipped = false
            }
        };
    }

    public async Task<bool> EquipItemAsync(Guid childProfileId, Guid itemId)
    {
        // Check if owned
        var isOwned = await _avatarRepository.IsItemOwnedAsync(childProfileId, itemId);
        if (!isOwned)
            return false;

        // Get item to check type
        var item = await _avatarRepository.GetItemByIdAsync(itemId);
        if (item == null)
            return false;

        // Check if same type item is already equipped
        var existingEquipped = await _avatarRepository.GetEquippedItemByTypeAsync(
            childProfileId, 
            (int)item.ItemType);

        // If exists, unequip it first
        if (existingEquipped != null)
        {
            await _avatarRepository.UnequipItemByTypeAsync(childProfileId, (int)item.ItemType);
        }

        // Equip new item
        var equippedItem = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            ItemId = itemId,
            EquippedAt = DateTime.UtcNow
        };

        await _avatarRepository.EquipItemAsync(equippedItem);
        return true;
    }

    public async Task<bool> UnequipItemAsync(Guid childProfileId, Guid itemId)
    {
        await _avatarRepository.UnequipItemAsync(childProfileId, itemId);
        return true;
    }

    public async Task<ChildAvatarDto> GetChildAvatarAsync(Guid childProfileId)
    {
        var child = await _childProfileRepository.GetByIdAsync(childProfileId);
        var equippedItems = await _avatarRepository.GetChildEquippedItemsAsync(childProfileId);

        return new ChildAvatarDto
        {
            ChildProfileId = childProfileId,
            ChildName = child?.Name ?? string.Empty,
            Avatar = null, // Will be implemented with default avatar
            EquippedItems = equippedItems.Select(e => new EquippedItemDto
            {
                ItemId = e.ItemId,
                Name = e.Item.Name,
                ItemType = (int)e.Item.ItemType,
                ItemTypeName = e.Item.ItemType.ToString(),
                ImageUrl = e.Item.ImageUrl,
                EquippedAt = e.EquippedAt
            }).ToList(),
            TotalPoints = child?.TotalCoins ?? 0
        };
    }

    public async Task<List<AvatarItemDto>> GetOwnedItemsAsync(Guid childProfileId)
    {
        var ownedItems = await _avatarRepository.GetChildOwnedItemsAsync(childProfileId);
        var equippedItems = await _avatarRepository.GetChildEquippedItemsAsync(childProfileId);
        var equippedItemIds = equippedItems.Select(e => e.ItemId).ToHashSet();

        return ownedItems.Select(o => new AvatarItemDto
        {
            Id = o.Item.Id,
            Name = o.Item.Name,
            ItemType = (int)o.Item.ItemType,
            ItemTypeName = o.Item.ItemType.ToString(),
            PointCost = o.Item.PointCost,
            ImageUrl = o.Item.ImageUrl,
            Category = o.Item.Category,
            IsOwned = true,
            IsEquipped = equippedItemIds.Contains(o.ItemId)
        }).ToList();
    }

    public async Task<List<EquippedItemDto>> GetEquippedItemsAsync(Guid childProfileId)
    {
        var equippedItems = await _avatarRepository.GetChildEquippedItemsAsync(childProfileId);

        return equippedItems.Select(e => new EquippedItemDto
        {
            ItemId = e.ItemId,
            Name = e.Item.Name,
            ItemType = (int)e.Item.ItemType,
            ItemTypeName = e.Item.ItemType.ToString(),
            ImageUrl = e.Item.ImageUrl,
            EquippedAt = e.EquippedAt
        }).ToList();
    }

    public async Task UpdateCharacterAsync(Guid childProfileId, string characterKey)
    {
        var child = await _childProfileRepository.GetByIdAsync(childProfileId)
            ?? throw new Exception("Çocuk profili bulunamadı");
        child.AvatarImageUrl = characterKey;
        await _childProfileRepository.UpdateAsync(child);
    }
}
