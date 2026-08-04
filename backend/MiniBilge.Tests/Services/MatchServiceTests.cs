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
            entertainmentServiceMock.Object,
            new Mock<IDailyUsageService>().Object);

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
            entertainmentServiceMock.Object,
            new Mock<IDailyUsageService>().Object);

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

        matchRepositoryMock
            .Setup(x => x.ExpireOldMatchRequestsAsync(60))
            .ReturnsAsync(new List<MatchRequest>());

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            new Mock<IDailyUsageService>().Object);

        // Act
        await service.ExpireOldRequestsAsync(60);

        // Assert
        matchRepositoryMock.Verify(x => x.ExpireOldMatchRequestsAsync(60), Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_RequestMatch_WithActingUser_ShouldConsumeLiveMatch()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var subjectId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync((MatchRequest?)null);
        childProfileRepositoryMock
            .Setup(x => x.GetByIdAsync(childId))
            .ReturnsAsync(new ChildProfile { Id = childId, GradeLevel = GradeLevel.Grade1 });
        educationRepositoryMock
            .Setup(x => x.GetAllSubjectsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Subject>());
        matchRepositoryMock
            .Setup(x => x.CreateMatchRequestAsync(childId, subjectId, levelId, null, null, null))
            .ReturnsAsync(new MatchRequest { Id = Guid.NewGuid(), ChildProfileId = childId, Status = MatchRequestStatus.Waiting });
        matchRepositoryMock
            .Setup(x => x.GetPendingMatchRequestsByLevelAsync(levelId))
            .ReturnsAsync(new List<MatchRequest>());

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        await service.RequestMatchAsync(childId, subjectId, levelId, actingUserId: userId);

        // Assert
        dailyUsageServiceMock.Verify(
            x => x.ConsumeAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
        matchRepositoryMock.Verify(
            x => x.CreateMatchRequestAsync(childId, subjectId, levelId, null, null, null),
            Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_RequestMatch_WhenLimitExceeded_ShouldNotCreateRequest()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var subjectId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync((MatchRequest?)null);
        childProfileRepositoryMock
            .Setup(x => x.GetByIdAsync(childId))
            .ReturnsAsync(new ChildProfile { Id = childId, GradeLevel = GradeLevel.Grade1 });
        educationRepositoryMock
            .Setup(x => x.GetAllSubjectsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Subject>());
        dailyUsageServiceMock
            .Setup(x => x.ConsumeAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()))
            .ThrowsAsync(new DailyUsageLimitExceededException(new DailyUsageStatusDto { FeatureKey = "live_match", Allowed = false }));

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var act = async () => await service.RequestMatchAsync(childId, subjectId, levelId, actingUserId: userId);

        // Assert
        await act.Should().ThrowAsync<DailyUsageLimitExceededException>();
        matchRepositoryMock.Verify(
            x => x.CreateMatchRequestAsync(It.IsAny<Guid>(), It.IsAny<Guid?>(), It.IsAny<Guid?>(),
                It.IsAny<AdultCompetitionType?>(), It.IsAny<string?>(), It.IsAny<string?>()),
            Times.Never);
    }

    // QA (h): Yeniden bağlanma / mükerrer arama zaten aktif istek varken ikinci hak TÜKETMEZ.
    [Fact]
    public async Task MatchmakingService_RequestMatch_WhenActiveRequestExists_ShouldNotConsumeAgain()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var existing = new MatchRequest { Id = Guid.NewGuid(), ChildProfileId = childId, Status = MatchRequestStatus.Waiting };

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync(existing);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var result = await service.RequestMatchAsync(childId, actingUserId: userId);

        // Assert: mevcut istek döner, yeni tüketim/kayıt olmaz.
        result.Id.Should().Be(existing.Id);
        dailyUsageServiceMock.Verify(
            x => x.ConsumeAsync(It.IsAny<Guid>(), It.IsAny<Guid>(), It.IsAny<string>(), It.IsAny<CancellationToken>()),
            Times.Never);
        matchRepositoryMock.Verify(
            x => x.CreateMatchRequestAsync(It.IsAny<Guid>(), It.IsAny<Guid?>(), It.IsAny<Guid?>(),
                It.IsAny<AdultCompetitionType?>(), It.IsAny<string?>(), It.IsAny<string?>()),
            Times.Never);
    }

    // QA (f): İstek kaydı teknik hatayla oluşturulamazsa rezerve edilen hak İADE edilir.
    [Fact]
    public async Task MatchmakingService_RequestMatch_WhenCreateFails_ShouldRefundReservedRight()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var subjectId = Guid.NewGuid();
        var levelId = Guid.NewGuid();

        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync((MatchRequest?)null);
        childProfileRepositoryMock
            .Setup(x => x.GetByIdAsync(childId))
            .ReturnsAsync(new ChildProfile { Id = childId, GradeLevel = GradeLevel.Grade1 });
        educationRepositoryMock
            .Setup(x => x.GetAllSubjectsAsync(It.IsAny<CancellationToken>()))
            .ReturnsAsync(new List<Subject>());
        matchRepositoryMock
            .Setup(x => x.CreateMatchRequestAsync(childId, subjectId, levelId, null, null, null))
            .ThrowsAsync(new InvalidOperationException("db down"));

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var act = async () => await service.RequestMatchAsync(childId, subjectId, levelId, actingUserId: userId);

        // Assert: hata yukarı fırlar ve tüketilen hak geri verilir.
        await act.Should().ThrowAsync<InvalidOperationException>();
        dailyUsageServiceMock.Verify(
            x => x.ConsumeAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_CancelMatchRequest_WithActingUser_ShouldRefundLiveMatch()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        matchRepositoryMock
            .Setup(x => x.GetActiveMatchRequestByChildIdAsync(childId))
            .ReturnsAsync(new MatchRequest { Id = Guid.NewGuid(), ChildProfileId = childId, Status = MatchRequestStatus.Waiting });

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        await service.CancelMatchRequestAsync(childId, userId);

        // Assert
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_ExpireOldRequests_ShouldRefundEachExpiredParent()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var childId = Guid.NewGuid();
        var userId = Guid.NewGuid();
        var expired = new List<MatchRequest>
        {
            new MatchRequest
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childId,
                Status = MatchRequestStatus.Expired,
                ChildProfile = new ChildProfile
                {
                    Id = childId,
                    ParentProfile = new ParentProfile { UserId = userId }
                }
            }
        };
        matchRepositoryMock
            .Setup(x => x.ExpireOldMatchRequestsAsync(60))
            .ReturnsAsync(expired);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        await service.ExpireOldRequestsAsync(60);

        // Assert
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(userId, childId, "live_match", It.IsAny<CancellationToken>()),
            Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_ExpireStaleMatchSessions_ShouldRefundBothPlayersAndCancelSession()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var child1 = Guid.NewGuid();
        var user1 = Guid.NewGuid();
        var child2 = Guid.NewGuid();
        var user2 = Guid.NewGuid();

        var session = new MatchSession
        {
            Id = Guid.NewGuid(),
            Status = MatchSessionStatus.Created,
            StartedAt = null,
            Participants = new List<MatchParticipant>
            {
                new MatchParticipant
                {
                    ChildProfileId = child1,
                    ChildProfile = new ChildProfile { Id = child1, ParentProfile = new ParentProfile { UserId = user1 } }
                },
                new MatchParticipant
                {
                    ChildProfileId = child2,
                    ChildProfile = new ChildProfile { Id = child2, ParentProfile = new ParentProfile { UserId = user2 } }
                }
            }
        };
        matchRepositoryMock
            .Setup(x => x.GetStaleCreatedMatchSessionsAsync(It.IsAny<DateTime>()))
            .ReturnsAsync(new List<MatchSession> { session });

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        await service.ExpireStaleMatchSessionsAsync(90);

        // Assert — her iki oyuncuya iade
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(user1, child1, "live_match", It.IsAny<CancellationToken>()), Times.Once);
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(user2, child2, "live_match", It.IsAny<CancellationToken>()), Times.Once);
        // Oturum iptal edilir (geçmiş/sıralama/galibiyet dışında kalır)
        session.Status.Should().Be(MatchSessionStatus.Cancelled);
        matchRepositoryMock.Verify(x => x.UpdateMatchSessionAsync(session), Times.Once);
    }

    [Fact]
    public async Task MatchmakingService_ExpireStaleMatchSessions_WhenNoStaleSessions_ShouldNotRefund()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        matchRepositoryMock
            .Setup(x => x.GetStaleCreatedMatchSessionsAsync(It.IsAny<DateTime>()))
            .ReturnsAsync(new List<MatchSession>());

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        await service.ExpireStaleMatchSessionsAsync(90);

        // Assert
        dailyUsageServiceMock.Verify(
            x => x.RefundAsync(It.IsAny<Guid>(), It.IsAny<Guid>(), It.IsAny<string>(), It.IsAny<CancellationToken>()),
            Times.Never);
        matchRepositoryMock.Verify(x => x.UpdateMatchSessionAsync(It.IsAny<MatchSession>()), Times.Never);
    }

    [Fact]
    public async Task MatchmakingService_GetRankedStatus_UnderDailyCap_NextGameRanked()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var child = Guid.NewGuid();
        matchRepositoryMock
            .Setup(x => x.CountRankingLiveMatchesTodayAsync(child, It.IsAny<DateTime>(), Guid.Empty))
            .ReturnsAsync(2);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var status = await service.GetLiveMatchRankedStatusAsync(child);

        // Assert — günde 5 sınırının altında: sıralamaya sayar
        status.RankedRemainingToday.Should().Be(3);
        status.DailyRankedLimit.Should().Be(5);
        status.NextGameRanked.Should().BeTrue();
        status.VsOpponentEligible.Should().BeNull();
    }

    [Fact]
    public async Task MatchmakingService_GetRankedStatus_AtDailyCap_NotRanked()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var child = Guid.NewGuid();
        matchRepositoryMock
            .Setup(x => x.CountRankingLiveMatchesTodayAsync(child, It.IsAny<DateTime>(), Guid.Empty))
            .ReturnsAsync(5);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var status = await service.GetLiveMatchRankedStatusAsync(child);

        // Assert — günlük sınır dolu: sıralamaya saymaz
        status.RankedRemainingToday.Should().Be(0);
        status.NextGameRanked.Should().BeFalse();
    }

    [Fact]
    public async Task MatchmakingService_GetRankedStatus_SameOpponentCapReached_NotRanked()
    {
        // Arrange
        var matchRepositoryMock = new Mock<IMatchRepository>();
        var childProfileRepositoryMock = new Mock<IChildProfileRepository>();
        var educationRepositoryMock = new Mock<IEducationRepository>();
        var matchNotifierMock = new Mock<IMatchNotifier>();
        var entertainmentServiceMock = new Mock<IEntertainmentQuizService>();
        var dailyUsageServiceMock = new Mock<IDailyUsageService>();

        var child = Guid.NewGuid();
        var opponent = Guid.NewGuid();
        matchRepositoryMock
            .Setup(x => x.CountRankingLiveMatchesTodayAsync(child, It.IsAny<DateTime>(), Guid.Empty))
            .ReturnsAsync(1);
        matchRepositoryMock
            .Setup(x => x.CountRankingLiveMatchesVsOpponentTodayAsync(child, opponent, It.IsAny<DateTime>(), Guid.Empty))
            .ReturnsAsync(2);

        var service = new MatchmakingService(
            matchRepositoryMock.Object,
            childProfileRepositoryMock.Object,
            educationRepositoryMock.Object,
            matchNotifierMock.Object,
            entertainmentServiceMock.Object,
            dailyUsageServiceMock.Object);

        // Act
        var status = await service.GetLiveMatchRankedStatusAsync(child, opponent);

        // Assert — günlük hak var ama aynı rakip sınırı dolu: sıralamaya saymaz
        status.RankedRemainingToday.Should().Be(4);
        status.VsOpponentEligible.Should().BeFalse();
        status.NextGameRanked.Should().BeFalse();
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
