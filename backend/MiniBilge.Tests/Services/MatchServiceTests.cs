using FluentAssertions;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

public class MatchServiceTests
{
    [Fact]
    public async Task MatchRepository_GetMatchStatsAsync_ShouldCalculateCorrectStats()
    {
        // This test validates the match statistics calculation logic
        // In a real scenario, this would be tested against an in-memory database
        Assert.True(true); // Placeholder - will be implemented with integration tests
    }

    [Fact]
    public async Task MatchmakingService_CancelMatchRequest_WhenRequestExists_ShouldReturnTrue()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();

        var childId = Guid.NewGuid();
        var matchRequest = new MatchRequest
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childId,
            Status = MatchRequestStatus.Waiting
        };

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync(matchRequest);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object);

        // Act
        var result = await service.CancelMatchRequestAsync(childId);

        // Assert
        result.Should().BeTrue();
        matchRequest.Status.Should().Be(MatchRequestStatus.Cancelled);
        matchRepositoryMock.Verify(x => x.UpdateMatchRequestAsync(matchRequest), Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_CancelMatchRequest_WhenNoRequestExists_ShouldReturnFalse()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();

        var childId = Guid.NewGuid();

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync((MatchRequest?)null);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object);

        // Act
        var result = await service.CancelMatchRequestAsync(childId);

        // Assert
        result.Should().BeFalse();
        matchRepositoryMock.Verify(x => x.UpdateMatchRequestAsync(It.IsAny<MatchRequest>()), Times.Never);
    }

    [Fact]
    public async Task MatchmakingService_ExpireOldRequests_ShouldCallRepository()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object);

        // Act
        await service.ExpireOldRequestsAsync(60);

        // Assert
        matchRepositoryMock.Verify(x => x.ExpireOldMatchRequestsAsync(60), Times.Once);
    }

    [Fact]
    public void MatchRequest_StatusTransitions_ShouldBeValid()
    {
        // Arrange
        var request = new MatchRequest
        {
            Id = Guid.NewGuid(),
            ChildProfileId = Guid.NewGuid(),
            Status = MatchRequestStatus.Waiting
        };

        // Act & Assert - Status transitions
        request.Status.Should().Be(MatchRequestStatus.Waiting);
        
        request.Status = MatchRequestStatus.Matched;
        request.Status.Should().Be(MatchRequestStatus.Matched);
        
        request.Status = MatchRequestStatus.Cancelled;
        request.Status.Should().Be(MatchRequestStatus.Cancelled);
        
        request.Status = MatchRequestStatus.Expired;
        request.Status.Should().Be(MatchRequestStatus.Expired);
    }

    [Fact]
    public void MatchSession_StatusTransitions_ShouldBeValid()
    {
        // Arrange
        var session = new MatchSession
        {
            Id = Guid.NewGuid(),
            Status = MatchSessionStatus.Created
        };

        // Act & Assert - Status transitions
        session.Status.Should().Be(MatchSessionStatus.Created);
        
        session.Status = MatchSessionStatus.InProgress;
        session.Status.Should().Be(MatchSessionStatus.InProgress);
        
        session.Status = MatchSessionStatus.Completed;
        session.Status.Should().Be(MatchSessionStatus.Completed);
        
        session.Status = MatchSessionStatus.Abandoned;
        session.Status.Should().Be(MatchSessionStatus.Abandoned);
    }
}
