using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Repositories;
using Xunit;

namespace MiniBilge.Tests.Repositories;

public class AvatarRepositoryTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly AvatarRepository _repository;

    public AvatarRepositoryTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;

        _context = new ApplicationDbContext(options);
        _repository = new AvatarRepository(_context);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    #region Avatar Tests

    [Fact]
    public async Task GetDefaultAvatarAsync_ShouldReturnDefaultAvatar()
    {
        // Arrange
        var defaultAvatar = new Avatar
        {
            Id = Guid.NewGuid(),
            Name = "Default Avatar",
            ImageUrl = "default.png",
            IsDefault = true,
            IsActive = true
        };
        _context.Avatars.Add(defaultAvatar);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetDefaultAvatarAsync();

        // Assert
        result.Should().NotBeNull();
        result!.Id.Should().Be(defaultAvatar.Id);
        result.IsDefault.Should().BeTrue();
    }

    [Fact]
    public async Task GetActiveItemsAsync_ShouldReturnOnlyActiveItems()
    {
        // Arrange
        var activeItem = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Active Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats",
            IsActive = true
        };
        var inactiveItem = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Inactive Hat",
            ItemType = ItemType.Hat,
            PointCost = 60,
            ImageUrl = "hat2.png",
            Category = "Hats",
            IsActive = false
        };
        _context.AvatarItems.AddRange(activeItem, inactiveItem);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetActiveItemsAsync();

        // Assert
        result.Should().HaveCount(1);
        result.First().Id.Should().Be(activeItem.Id);
    }

    #endregion

    #region ChildOwnedItem Tests

    [Fact]
    public async Task IsItemOwnedAsync_WithOwnedItem_ShouldReturnTrue()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        var ownedItem = new ChildOwnedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = itemId,
            PurchasedAt = DateTime.UtcNow
        };
        _context.ChildOwnedItems.Add(ownedItem);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.IsItemOwnedAsync(childId, itemId);

        // Assert
        result.Should().BeTrue();
    }

    [Fact]
    public async Task IsItemOwnedAsync_WithNotOwnedItem_ShouldReturnFalse()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        // Act
        var result = await _repository.IsItemOwnedAsync(childId, itemId);

        // Assert
        result.Should().BeFalse();
    }

    [Fact]
    public async Task AddOwnedItemAsync_ShouldAddItemToDatabase()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        var ownedItem = new ChildOwnedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = itemId,
            PurchasedAt = DateTime.UtcNow
        };

        // Act
        var result = await _repository.AddOwnedItemAsync(ownedItem);

        // Assert
        result.Should().NotBeNull();
        var dbItem = await _context.ChildOwnedItems.FindAsync(result.Id);
        dbItem.Should().NotBeNull();
        dbItem!.ChildProfileId.Should().Be(childId);
        dbItem.ItemId.Should().Be(itemId);
    }

    #endregion

    #region ChildEquippedItem Tests

    [Fact]
    public async Task GetEquippedItemByTypeAsync_WithEquippedItem_ShouldReturnItem()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var item = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };
        _context.AvatarItems.Add(item);
        
        var equippedItem = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = item.Id,
            EquippedAt = DateTime.UtcNow
        };
        _context.ChildEquippedItems.Add(equippedItem);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetEquippedItemByTypeAsync(childId, (int)ItemType.Hat);

        // Assert
        result.Should().NotBeNull();
        result!.ItemId.Should().Be(item.Id);
    }

    [Fact]
    public async Task UnequipItemByTypeAsync_ShouldMarkItemAsDeleted()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var item = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };
        _context.AvatarItems.Add(item);
        
        var equippedItem = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = item.Id,
            EquippedAt = DateTime.UtcNow
        };
        _context.ChildEquippedItems.Add(equippedItem);
        await _context.SaveChangesAsync();

        // Act
        await _repository.UnequipItemByTypeAsync(childId, (int)ItemType.Hat);

        // Assert
        var dbItem = await _context.ChildEquippedItems
            .IgnoreQueryFilters()
            .FirstOrDefaultAsync(e => e.Id == equippedItem.Id);
        dbItem.Should().NotBeNull();
        dbItem!.IsDeleted.Should().BeTrue();
    }

    [Fact]
    public async Task EquipItemAsync_ShouldAddItemToDatabase()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        var equippedItem = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = itemId,
            EquippedAt = DateTime.UtcNow
        };

        // Act
        var result = await _repository.EquipItemAsync(equippedItem);

        // Assert
        result.Should().NotBeNull();
        var dbItem = await _context.ChildEquippedItems.FindAsync(result.Id);
        dbItem.Should().NotBeNull();
        dbItem!.ChildProfileId.Should().Be(childId);
        dbItem.ItemId.Should().Be(itemId);
    }

    [Fact]
    public async Task GetChildEquippedItemsAsync_ShouldReturnEquippedItems()
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
        var glasses = new AvatarItem
        {
            Id = Guid.NewGuid(),
            Name = "Sunglasses",
            ItemType = ItemType.Glasses,
            PointCost = 75,
            ImageUrl = "glasses.png",
            Category = "Glasses"
        };
        _context.AvatarItems.AddRange(hat, glasses);

        var equippedHat = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = hat.Id,
            EquippedAt = DateTime.UtcNow
        };
        var equippedGlasses = new ChildEquippedItem
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            ItemId = glasses.Id,
            EquippedAt = DateTime.UtcNow
        };
        _context.ChildEquippedItems.AddRange(equippedHat, equippedGlasses);
        await _context.SaveChangesAsync();

        // Act
        var result = await _repository.GetChildEquippedItemsAsync(childId);

        // Assert
        result.Should().HaveCount(2);
        result.Select(e => e.ItemId).Should().Contain(new[] { hat.Id, glasses.Id });
    }

    #endregion
}
