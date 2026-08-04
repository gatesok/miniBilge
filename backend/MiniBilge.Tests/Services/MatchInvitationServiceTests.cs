using FluentAssertions;
using MiniBilge.Application.DTOs.Usage;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class MatchInvitationServiceTests
{
    private static (
        Mock<IMatchInvitationRepository> invitationRepo,
        Mock<IFriendshipRepository> friendshipRepo,
        Mock<IChildProfileRepository> childProfileRepo,
        Mock<IEducationRepository> educationRepo,
        Mock<ISocialNotifier> socialNotifier,
        Mock<INotificationService> notificationService,
        Mock<IMatchmakingService> matchmakingService,
        Mock<IDailyUsageService> dailyUsageService,
        MatchInvitationService service) CreateSut()
    {
        var invitationRepo      = new Mock<IMatchInvitationRepository>();
        var friendshipRepo      = new Mock<IFriendshipRepository>();
        var childProfileRepo    = new Mock<IChildProfileRepository>();
        var educationRepo       = new Mock<IEducationRepository>();
        var socialNotifier      = new Mock<ISocialNotifier>();
        var notificationService = new Mock<INotificationService>();
        var matchmakingService  = new Mock<IMatchmakingService>();
        var dailyUsageService   = new Mock<IDailyUsageService>();

        var service = new MatchInvitationService(
            invitationRepo.Object,
            friendshipRepo.Object,
            childProfileRepo.Object,
            educationRepo.Object,
            socialNotifier.Object,
            notificationService.Object,
            matchmakingService.Object,
            dailyUsageService.Object);

        return (invitationRepo, friendshipRepo, childProfileRepo, educationRepo,
                socialNotifier, notificationService, matchmakingService, dailyUsageService, service);
    }

    [Fact]
    public async Task SendInvite_WhenAccepted_ShouldConsumeLiveMatchForInviter()
    {
        // Arrange
        var sut = CreateSut();
        var inviterId = Guid.NewGuid();
        var inviteeId = Guid.NewGuid();
        var inviterUserId = Guid.NewGuid();

        sut.friendshipRepo
            .Setup(x => x.GetBetweenAsync(inviterId, inviteeId))
            .ReturnsAsync(new Friendship { Status = FriendshipStatus.Accepted });
        sut.childProfileRepo
            .Setup(x => x.GetParentUserIdAsync(inviterId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(inviterUserId);
        sut.invitationRepo
            .Setup(x => x.CreateAsync(inviterId, inviteeId, null))
            .ReturnsAsync(new MatchInvitation { Id = Guid.NewGuid(), InviterId = inviterId, InviteeId = inviteeId });

        // Act
        await sut.service.SendInviteAsync(inviterId, inviteeId, null);

        // Assert
        sut.dailyUsageService.Verify(
            x => x.ConsumeAsync(inviterUserId, inviterId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task SendInvite_WhenLimitExceeded_ShouldNotCreateInvitation()
    {
        // Arrange
        var sut = CreateSut();
        var inviterId = Guid.NewGuid();
        var inviteeId = Guid.NewGuid();
        var inviterUserId = Guid.NewGuid();

        sut.friendshipRepo
            .Setup(x => x.GetBetweenAsync(inviterId, inviteeId))
            .ReturnsAsync(new Friendship { Status = FriendshipStatus.Accepted });
        sut.childProfileRepo
            .Setup(x => x.GetParentUserIdAsync(inviterId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(inviterUserId);
        sut.dailyUsageService
            .Setup(x => x.ConsumeAsync(inviterUserId, inviterId, "live_match", It.IsAny<CancellationToken>()))
            .ThrowsAsync(new DailyUsageLimitExceededException(new DailyUsageStatusDto { FeatureKey = "live_match", Allowed = false }));

        // Act
        var act = async () => await sut.service.SendInviteAsync(inviterId, inviteeId, null);

        // Assert
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
        sut.invitationRepo.Verify(
            x => x.CreateAsync(It.IsAny<Guid>(), It.IsAny<Guid>(), It.IsAny<Guid?>()),
            Times.Never);
    }

    [Fact]
    public async Task Respond_WhenDeclined_ShouldRefundInviter()
    {
        // Arrange
        var sut = CreateSut();
        var invitationId = Guid.NewGuid();
        var inviterId = Guid.NewGuid();
        var inviteeId = Guid.NewGuid();
        var inviterUserId = Guid.NewGuid();

        sut.invitationRepo
            .Setup(x => x.GetByIdAsync(invitationId))
            .ReturnsAsync(new MatchInvitation
            {
                Id = invitationId,
                InviterId = inviterId,
                InviteeId = inviteeId,
                Status = MatchInvitationStatus.Pending,
                ExpiresAt = DateTime.UtcNow.AddMinutes(5)
            });
        sut.childProfileRepo
            .Setup(x => x.GetParentUserIdAsync(inviterId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(inviterUserId);

        // Act
        await sut.service.RespondAsync(invitationId, inviteeId, accept: false);

        // Assert
        sut.dailyUsageService.Verify(
            x => x.RefundAsync(inviterUserId, inviterId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
        sut.matchmakingService.Verify(
            x => x.CreateDirectMatchAsync(It.IsAny<Guid>(), It.IsAny<Guid>(), It.IsAny<Guid?>()),
            Times.Never);
    }

    [Fact]
    public async Task Respond_WhenAccepted_ShouldConsumeLiveMatchForInvitee()
    {
        // Arrange
        var sut = CreateSut();
        var invitationId = Guid.NewGuid();
        var inviterId = Guid.NewGuid();
        var inviteeId = Guid.NewGuid();
        var inviteeUserId = Guid.NewGuid();

        sut.invitationRepo
            .Setup(x => x.GetByIdAsync(invitationId))
            .ReturnsAsync(new MatchInvitation
            {
                Id = invitationId,
                InviterId = inviterId,
                InviteeId = inviteeId,
                Status = MatchInvitationStatus.Pending,
                ExpiresAt = DateTime.UtcNow.AddMinutes(5)
            });
        sut.childProfileRepo
            .Setup(x => x.GetParentUserIdAsync(inviteeId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(inviteeUserId);
        sut.matchmakingService
            .Setup(x => x.CreateDirectMatchAsync(inviterId, inviteeId, null))
            .ReturnsAsync(new MatchSession { Id = Guid.NewGuid() });
        sut.invitationRepo
            .Setup(x => x.GetOtherPendingByInviterAsync(inviterId, invitationId))
            .ReturnsAsync(new List<MatchInvitation>());

        // Act
        await sut.service.RespondAsync(invitationId, inviteeId, accept: true);

        // Assert
        sut.dailyUsageService.Verify(
            x => x.ConsumeAsync(inviteeUserId, inviteeId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task ExpireOld_ShouldRefundEachExpiredInviter()
    {
        // Arrange
        var sut = CreateSut();
        var inviterId = Guid.NewGuid();
        var inviterUserId = Guid.NewGuid();

        sut.invitationRepo
            .Setup(x => x.ExpireOldAsync())
            .ReturnsAsync(new List<MatchInvitation>
            {
                new MatchInvitation { Id = Guid.NewGuid(), InviterId = inviterId, Status = MatchInvitationStatus.Expired }
            });
        sut.childProfileRepo
            .Setup(x => x.GetParentUserIdAsync(inviterId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(inviterUserId);

        // Act
        await sut.service.ExpireOldAsync();

        // Assert
        sut.dailyUsageService.Verify(
            x => x.RefundAsync(inviterUserId, inviterId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }
}
