using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Moq;
using Xunit;
using GradeLevel = MiniBilge.Domain.Enums.GradeLevel;

namespace MiniBilge.Tests.Services;

public class AvatarServicePurchaseTests
{
    private readonly Mock<IAvatarRepository> _mockAvatarRepository;
    private readonly Mock<IChildProfileRepository> _mockChildProfileRepository;
    private readonly AvatarService _avatarService;

    public AvatarServicePurchaseTests()
    {
        _mockAvatarRepository = new Mock<IAvatarRepository>();
        _mockChildProfileRepository = new Mock<IChildProfileRepository>();
        _avatarService = new AvatarService(
            _mockAvatarRepository.Object,
            _mockChildProfileRepository.Object);
    }

    #region PurchaseItem Tests

    [Fact]
    public async Task PurchaseItemAsync_WithValidPurchase_ShouldSucceed()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        
        var child = new ChildProfile
        {
            Id = childId,
            Name = "Test Child",
            TotalCoins = 100,
            DateOfBirth = DateTime.UtcNow.AddYears(-7),
            GradeLevel = GradeLevel.Grade1,
            ParentProfileId = Guid.NewGuid()
        };

        var item = new AvatarItem
        {
            Id = itemId,
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats",
            IsActive = true
        };

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(child);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync(item);

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(false);

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
        result.Message.Should().Contain("başarıyla");
        result.RemainingPoints.Should().Be(50); // 100 - 50
        result.PurchasedItem.Should().NotBeNull();
        result.PurchasedItem!.Id.Should().Be(itemId);

        _mockChildProfileRepository.Verify(
            r => r.UpdateAsync(It.IsAny<ChildProfile>(), It.IsAny<CancellationToken>()),
            Times.Once);

        _mockAvatarRepository.Verify(
            r => r.AddOwnedItemAsync(It.IsAny<ChildOwnedItem>()),
            Times.Once);
    }

    [Fact]
    public async Task PurchaseItemAsync_WithInsufficientPoints_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        
        var child = new ChildProfile
        {
            Id = childId,
            Name = "Test Child",
            TotalCoins = 30, // Not enough for 50 point item
            DateOfBirth = DateTime.UtcNow.AddYears(-7),
            GradeLevel = Domain.Enums.GradeLevel.Grade1,
            ParentProfileId = Guid.NewGuid()
        };

        var item = new AvatarItem
        {
            Id = itemId,
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(child);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync(item);

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(false);

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeFalse();
        result.Message.Should().Contain("Yetersiz puan");
        result.RemainingPoints.Should().Be(30);
        result.PurchasedItem.Should().BeNull();

        _mockChildProfileRepository.Verify(
            r => r.UpdateAsync(It.IsAny<ChildProfile>(), It.IsAny<CancellationToken>()),
            Times.Never);

        _mockAvatarRepository.Verify(
            r => r.AddOwnedItemAsync(It.IsAny<ChildOwnedItem>()),
            Times.Never);
    }

    [Fact]
    public async Task PurchaseItemAsync_WithAlreadyOwnedItem_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        
        var child = new ChildProfile
        {
            Id = childId,
            Name = "Test Child",
            TotalCoins = 100,
            DateOfBirth = DateTime.UtcNow.AddYears(-7),
            GradeLevel = GradeLevel.Grade1,
            ParentProfileId = Guid.NewGuid()
        };

        var item = new AvatarItem
        {
            Id = itemId,
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(child);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync(item);

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(true); // Already owned

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeFalse();
        result.Message.Should().Contain("zaten sahipsin");
        result.PurchasedItem.Should().BeNull();

        _mockChildProfileRepository.Verify(
            r => r.UpdateAsync(It.IsAny<ChildProfile>(), It.IsAny<CancellationToken>()),
            Times.Never);

        _mockAvatarRepository.Verify(
            r => r.AddOwnedItemAsync(It.IsAny<ChildOwnedItem>()),
            Times.Never);
    }

    [Fact]
    public async Task PurchaseItemAsync_WithNonExistentChild_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync((ChildProfile?)null);

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeFalse();
        result.Message.Should().Contain("Çocuk profili bulunamadı");
    }

    [Fact]
    public async Task PurchaseItemAsync_WithNonExistentItem_ShouldFail()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        
        var child = new ChildProfile
        {
            Id = childId,
            Name = "Test Child",
            TotalCoins = 100,
            DateOfBirth = DateTime.UtcNow.AddYears(-7),
            GradeLevel = GradeLevel.Grade1,
            ParentProfileId = Guid.NewGuid()
        };

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(child);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync((AvatarItem?)null);

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeFalse();
        result.Message.Should().Contain("Aksesuar bulunamadı");
    }

    [Fact]
    public async Task PurchaseItemAsync_WithExactPoints_ShouldSucceedAndLeaveZero()
    {
        // Arrange
        var childId = Guid.NewGuid();
        var itemId = Guid.NewGuid();
        
        var child = new ChildProfile
        {
            Id = childId,
            Name = "Test Child",
            TotalCoins = 50, // Exact amount
            DateOfBirth = DateTime.UtcNow.AddYears(-7),
            GradeLevel = Domain.Enums.GradeLevel.Grade1,
            ParentProfileId = Guid.NewGuid()
        };

        var item = new AvatarItem
        {
            Id = itemId,
            Name = "Cool Hat",
            ItemType = ItemType.Hat,
            PointCost = 50,
            ImageUrl = "hat.png",
            Category = "Hats"
        };

        _mockChildProfileRepository
            .Setup(r => r.GetByIdAsync(childId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(child);

        _mockAvatarRepository
            .Setup(r => r.GetItemByIdAsync(itemId))
            .ReturnsAsync(item);

        _mockAvatarRepository
            .Setup(r => r.IsItemOwnedAsync(childId, itemId))
            .ReturnsAsync(false);

        // Act
        var result = await _avatarService.PurchaseItemAsync(childId, itemId);

        // Assert
        result.Should().NotBeNull();
        result.Success.Should().BeTrue();
        result.RemainingPoints.Should().Be(0);

        _mockChildProfileRepository.Verify(
            r => r.UpdateAsync(It.IsAny<ChildProfile>(), It.IsAny<CancellationToken>()),
            Times.Once);
    }

    #endregion
}
