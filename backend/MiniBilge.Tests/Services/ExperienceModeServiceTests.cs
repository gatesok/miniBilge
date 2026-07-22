using FluentAssertions;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Moq;

namespace MiniBilge.Tests.Services;

public class ExperienceModeServiceTests
{
    private readonly Mock<IUserRepository> _userRepository = new();

    [Fact]
    public async Task GetAsync_ExistingUser_ReturnsCurrentMode()
    {
        var userId = Guid.NewGuid();
        _userRepository
            .Setup(repository => repository.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(new User { Id = userId, ExperienceMode = ExperienceMode.Family });

        var service = new ExperienceModeService(_userRepository.Object);
        var result = await service.GetAsync(userId);

        result.Should().NotBeNull();
        result!.Mode.Should().Be("Family");
        result.IsSelected.Should().BeTrue();
    }

    [Theory]
    [InlineData("child", ExperienceMode.Child)]
    [InlineData("Adult", ExperienceMode.Adult)]
    [InlineData(" FAMILY ", ExperienceMode.Family)]
    public async Task UpdateAsync_ValidMode_PersistsNormalizedMode(
        string requestedMode,
        ExperienceMode expectedMode)
    {
        var userId = Guid.NewGuid();
        var user = new User { Id = userId, ExperienceMode = ExperienceMode.Family };
        _userRepository
            .Setup(repository => repository.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        var service = new ExperienceModeService(_userRepository.Object);
        var result = await service.UpdateAsync(userId, requestedMode);

        result!.Mode.Should().Be(expectedMode.ToString());
        user.ExperienceMode.Should().Be(expectedMode);
        _userRepository.Verify(
            repository => repository.UpdateAsync(user, It.IsAny<CancellationToken>()),
            expectedMode == ExperienceMode.Family ? Times.Never() : Times.Once());
    }

    [Fact]
    public async Task UpdateAsync_InvalidMode_DoesNotReadOrUpdateUser()
    {
        var service = new ExperienceModeService(_userRepository.Object);

        var action = () => service.UpdateAsync(Guid.NewGuid(), "invalid");

        await action.Should().ThrowAsync<ArgumentException>();
        _userRepository.Verify(
            repository => repository.UpdateAsync(It.IsAny<User>(), It.IsAny<CancellationToken>()),
            Times.Never());
    }

    [Fact]
    public async Task UpdateAsync_SameModeButNotSelected_MarksOnboardingComplete()
    {
        var userId = Guid.NewGuid();
        var user = new User
        {
            Id = userId,
            ExperienceMode = ExperienceMode.Family,
            HasSelectedExperienceMode = false
        };
        _userRepository
            .Setup(repository => repository.GetByIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(user);

        var service = new ExperienceModeService(_userRepository.Object);
        var result = await service.UpdateAsync(userId, "Family");

        result!.IsSelected.Should().BeTrue();
        user.HasSelectedExperienceMode.Should().BeTrue();
        _userRepository.Verify(
            repository => repository.UpdateAsync(user, It.IsAny<CancellationToken>()),
            Times.Once());
    }

    [Fact]
    public async Task UpdateAsync_MissingUser_ReturnsNull()
    {
        _userRepository
            .Setup(repository => repository.GetByIdAsync(It.IsAny<Guid>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((User?)null);

        var service = new ExperienceModeService(_userRepository.Object);
        var result = await service.UpdateAsync(Guid.NewGuid(), "Adult");

        result.Should().BeNull();
    }
}
