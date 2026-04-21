using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class AvatarServiceEquipTests
{
    private readonly Mock<IAvatarRepository> _mockAvatarRepository;
    private readonly Mock<IChildProfileRepository> _mockChildProfileRepository;
    private readonly AvatarService _avatarService;

    public AvatarServiceEquipTests()
    {
        _mockAvatarRepository = new Mock<IAvatarRepository>();
        _mockChildProfileRepository = new Mock<IChildProfileRepository>();
        _avatarService = new AvatarService(
            _mockAvatarRepository.Object,
            _mockChildProfileRepository.Object);
    }

    #region EquipItem Tests

    [Fact]
    public async Task EquipItemAsync_WithOwnedItem_ShouldSucceed()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        var item = new AvatarItem
        {
            Id = itemId,
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(true);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync(item);

        _mockAvatarRepository
            .Setup(r => r.GetEquippedItemByTypeAsync(childId, (int)ItemType.Hat))
            .ReturnsAsync((ChildEquippedItem?)null);

        // Act
        var result = await _avatarService.EquipItemAsync(childId, itemId);

        // Assert
        result.Should().BeTrue();

        _mockAvatarRepository.Verify(
            r => r.EquipItemAsync(It.Is<ChildEquippedItem>(
                e => e.ChildProfileId == childId && e.ItemId == itemId)),
            Times.Once);
    }

    [Fact]
    public async Task EquipItemAsync_WithNotOwnedItem_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(false);

        // Act
        var result = await _avatarService.EquipItemAsync(childId, itemId);

        // Assert
        result.Should().BeFalse();

        _mockAvatarRepository.Verify(
            r => r.EquipItemAsync(It.IsAny<ChildEquippedItem>()),
            Times.Never);
    }

    [Fact]
    public async Task EquipItemAsync_WithSameTypeAlreadyEquipped_ShouldUnequipOldAndEquipNew()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var oldItemId = Guid.NewGuid();
        var newItemId = Guid.NewGuid();

        var oldItem = new AvatarItem
        {
            Id = oldItemId,
            Name = "Old Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "old-hat.png",
            Category = "Hats"
        };

        var newItem = new AvatarItem
        {
            Id = newItemId,
            Name = "New Hat",
            ItemType = ItemType.Hat,
            PointCost = 75,
            ImageUrl = "new-hat.png",
            Category = "Hats"
        };

        var existingEquipped = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = oldItemId,
            EquippedAt = DateTime.UtcNow.AddHours(-1)
        };

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, newItemId))
            .ReturnsAsync(true);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(newItemId))
            .ReturnsAsync(newItem);

        _mockAvatarRepository
            .Setup(r => r.GetEquippedItemByTypeAsync(childId, (int)ItemType.Hat))
            .ReturnsAsync(existingEquipped);

        // Act
        var result = await _avatarService.EquipItemAsync(childId, newItemId);

        // Assert
        result.Should().BeTrue();

        // Verify old item was unequipped
        _mockAvatarRepository.Verify(
            r => r.UnequipItemByTypeAsync(childId, (int)ItemType.Hat),
            Times.Once);

        // Verify new item was equipped
        _mockAvatarRepository.Verify(
            r => r.EquipItemAsync(It.Is<ChildEquippedItem>(
                e => e.ChildProfileId == childId && e.ItemId == newItemId)),
            Times.Once);
    }

    [Fact]
    public async Task EquipItemAsync_WithDifferentTypeItemsAlreadyEquipped_ShouldNotUnequipOthers()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var glassesId = Guid.NewGuid();

        var glasses = new AvatarItem
        {
            Id = glassesId,
            Name = "Cool Glasses",
            ItemType = ItemType.Glasses,
            PointCost = 75,
            ImageUrl = "glasses.png",
            Category = "Glasses"
        };

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, glassesId))
            .ReturnsAsync(true);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(glassesId))
            .ReturnsAsync(glasses);

        _mockAvatarRepository
            .Setup(r => r.GetEquippedItemByTypeAsync(childId, (int)ItemType.Glasses))
            .ReturnsAsync((ChildEquippedItem?)null);

        // Act
        var result = await _avatarService.EquipItemAsync(childId, glassesId);

        // Assert
        result.Should().BeTrue();

        // Verify only glasses type was checked, not other types
        _mockAvatarRepository.Verify(
            r => r.GetEquippedItemByTypeAsync(childId, (int)ItemType.Glasses),
            Times.Once);

        _mockAvatarRepository.Verify(
            r => r.UnequipItemByTypeAsync(childId, It.IsAny<int>()),
            Times.Never);
    }

    [Fact]
    public async Task EquipItemAsync_WithNonExistentItem_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(true);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync((AvatarItem?)null);

        // Act
        var result = await _avatarService.EquipItemAsync(childId, itemId);

        // Assert
        result.Should().BeFalse();

        _mockAvatarRepository.Verify(
            r => r.EquipItemAsync(It.IsAny<ChildEquippedItem>()),
            Times.Never);
    }

    #endregion

    #region UnequipItem Tests

    [Fact]
    public async Task UnequipItemAsync_ShouldCallRepositoryUnequip()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        // Act
        var result = await _avatarService.UnequipItemAsync(childId, itemId);

        // Assert
        result.Should().BeTrue();

        _mockAvatarRepository.Verify(
            r => r.UnequipItemAsync(childId, itemId),
            Times.Once);
    }

    [Fact]
    public async Task UnequipItemAsync_WithMultipleItems_ShouldOnlyUnequipSpecifiedItem()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var hatId = Guid.NewGuid();
        var glassesId = Guid.NewGuid();

        // Act - Unequip only hat
        await _avatarService.UnequipItemAsync(childId, hatId);

        // Assert
        _mockAvatarRepository.Verify(
            r => r.UnequipItemAsync(childId, hatId),
            Times.Once);

        _mockAvatarRepository.Verify(
            r => r.UnequipItemAsync(childId, glassesId),
            Times.Never);
    }

    #endregion

    #region GetEquippedItems Tests

    [Fact]
    public async Task GetEquippedItemsAsync_ShouldReturnEquippedItemsDtos()
    {
        // Arrange
        var childId = Guid.NewGuid();
        
        var hat = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };

        var equippedHat = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = hat.Id,
            Item = hat,
            EquippedAt = DateTime.UtcNow
        };

        _mockAvatarRepository
            .Setup(r => r.GetChildEquippedItemsAsync(childId))
            .ReturnsAsync(new List<ChildEquippedItem> { equippedHat });

        // Act
        var result = await _avatarService.GetEquippedItemsAsync(childId);

        // Assert
        result.Should().HaveCount(1);
        var dto = result.First();
        dto.ItemId.Should().Be(hat.Id);
        dto.Name.Should().Be("Cool Hat");
        dto.ItemType.Should().Be((int)ItemType.Hat);
        dto.ItemTypeName.Should().Be("Hat");
    }

    [Fact]
    public async Task GetEquippedItemsAsync_WithNoEquippedItems_ShouldReturnEmptyList()
    {
        // Arrange
        var childId = Guid.NewGuid();

        _mockAvatarRepository
            .Setup(r => r.GetChildEquippedItemsAsync(childId))
            .ReturnsAsync(new List<ChildEquippedItem>());

        // Act
        var result = await _avatarService.GetEquippedItemsAsync(childId);

        // Assert
        result.Should().BeEmpty();
    }

    #endregion
}
