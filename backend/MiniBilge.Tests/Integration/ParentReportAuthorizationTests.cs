using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.API.Controllers;
using MiniBilge.Application.DTOs.Profile;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using Moq;
using System.Security.Claims;
using Xunit;

namespace MiniBilge.Tests.Integration;

/// <summary>
/// Sprint 7 Authorization Tests
/// Validates that parents can only access their own children's reports.
/// </summary>
public class ParentReportAuthorizationTests
{
    private readonly Mock<IParentReportingService> _mockReportingService;
    private readonly Mock<IChildProfileService> _mockChildProfileService;

    private static readonly Guid ParentUserId = Guid.NewGuid();
    private static readonly Guid OtherParentUserId = Guid.NewGuid();
    private static readonly Guid OwnChildId = Guid.NewGuid();
    private static readonly Guid OtherChildId = Guid.NewGuid();

    public ParentReportAuthorizationTests()
    {
        _mockReportingService = new Mock<IParentReportingService>();
        _mockChildProfileService = new Mock<IChildProfileService>();
    }

    // -------------------------------------------------------------------
    // Helpers
    // -------------------------------------------------------------------

    private ParentReportController CreateControllerFor(Guid userId)
    {
        var controller = new ParentReportController(
            _mockReportingService.Object,
            _mockChildProfileService.Object);

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, userId.ToString()),
            new(ClaimTypes.Role, "Parent"),
        };

        controller.ControllerContext = new ControllerContext
        {
            HttpContext = new DefaultHttpContext
            {
                User = new ClaimsPrincipal(new ClaimsIdentity(claims, "Test")),
            },
        };

        return controller;
    }

    private void SetupChildrenForParent(Guid userId, IEnumerable<Guid> childIds)
    {
        var dtos = childIds.Select(id => new ChildProfileDto { Id = id, Name = "Test" }).ToList();
        _mockChildProfileService
            .Setup(s => s.GetChildrenByUserIdAsync(userId, It.IsAny<CancellationToken>()))
            .ReturnsAsync(dtos);
    }

    // -------------------------------------------------------------------
    // Daily Summary
    // -------------------------------------------------------------------

    [Fact]
    public async Task GetDailySummary_OwnChild_ShouldReturn200()
    {
        // Arrange
        SetupChildrenForParent(ParentUserId, new[] { OwnChildId });
        _mockReportingService
            .Setup(s => s.GetDailySummaryAsync(OwnChildId, It.IsAny<DateTime>()))
            .ReturnsAsync(new Application.DTOs.ParentReport.DailySummaryDto { ChildId = OwnChildId });

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetDailySummary(OwnChildId, null);

        // Assert
        result.Result.Should().BeOfType<OkObjectResult>();
    }

    [Fact]
    public async Task GetDailySummary_AnotherParentsChild_ShouldReturn403()
    {
        // Arrange — bu ebeveynin hiç çocuğu yok
        SetupChildrenForParent(ParentUserId, Enumerable.Empty<Guid>());

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetDailySummary(OtherChildId, null);

        // Assert
        result.Result.Should().BeOfType<ForbidResult>();
    }

    // -------------------------------------------------------------------
    // Weekly Summary
    // -------------------------------------------------------------------

    [Fact]
    public async Task GetWeeklySummary_OwnChild_ShouldReturn200()
    {
        // Arrange
        SetupChildrenForParent(ParentUserId, new[] { OwnChildId });
        _mockReportingService
            .Setup(s => s.GetWeeklySummaryAsync(OwnChildId, It.IsAny<DateTime>()))
            .ReturnsAsync(new Application.DTOs.ParentReport.WeeklySummaryDto { ChildId = OwnChildId });

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeeklySummary(OwnChildId, null);

        // Assert
        result.Result.Should().BeOfType<OkObjectResult>();
    }

    [Fact]
    public async Task GetWeeklySummary_AnotherParentsChild_ShouldReturn403()
    {
        // Arrange
        SetupChildrenForParent(ParentUserId, Enumerable.Empty<Guid>());

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeeklySummary(OtherChildId, null);

        // Assert
        result.Result.Should().BeOfType<ForbidResult>();
    }

    // -------------------------------------------------------------------
    // Weak Topics
    // -------------------------------------------------------------------

    [Fact]
    public async Task GetWeakTopics_OwnChild_ShouldReturn200()
    {
        // Arrange
        SetupChildrenForParent(ParentUserId, new[] { OwnChildId });
        _mockReportingService
            .Setup(s => s.GetWeakTopicsAsync(OwnChildId, It.IsAny<int>()))
            .ReturnsAsync(new List<Application.DTOs.ParentReport.WeakTopicDto>());

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeakTopics(OwnChildId);

        // Assert
        result.Result.Should().BeOfType<OkObjectResult>();
    }

    [Fact]
    public async Task GetWeakTopics_AnotherParentsChild_ShouldReturn403()
    {
        // Arrange
        SetupChildrenForParent(ParentUserId, Enumerable.Empty<Guid>());

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeakTopics(OtherChildId);

        // Assert
        result.Result.Should().BeOfType<ForbidResult>();
    }

    [Fact]
    public async Task GetWeakTopics_InvalidTopN_ShouldReturn400()
    {
        // Arrange — topN = 0 geçersiz
        SetupChildrenForParent(ParentUserId, new[] { OwnChildId });

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeakTopics(OwnChildId, topN: 0);

        // Assert
        result.Result.Should().BeOfType<BadRequestObjectResult>();
    }

    [Fact]
    public async Task GetWeakTopics_TopNAboveMax_ShouldReturn400()
    {
        // Arrange — topN = 21 geçersiz (max 20)
        SetupChildrenForParent(ParentUserId, new[] { OwnChildId });

        var controller = CreateControllerFor(ParentUserId);

        // Act
        var result = await controller.GetWeakTopics(OwnChildId, topN: 21);

        // Assert
        result.Result.Should().BeOfType<BadRequestObjectResult>();
    }

    // -------------------------------------------------------------------
    // Cross-parent isolation
    // -------------------------------------------------------------------

    [Fact]
    public async Task GetDailySummary_ParentWithMultipleChildren_CanAccessOwnButNotOthers()
    {
        // Arrange
        var child1 = Guid.NewGuid();
        var child2 = Guid.NewGuid();
        var foreignChild = Guid.NewGuid();

        SetupChildrenForParent(ParentUserId, new[] { child1, child2 });
        _mockReportingService
            .Setup(s => s.GetDailySummaryAsync(It.IsAny<Guid>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new Application.DTOs.ParentReport.DailySummaryDto());

        var controller = CreateControllerFor(ParentUserId);

        // Act & Assert — kendi çocukları için 200
        var r1 = await controller.GetDailySummary(child1, null);
        var r2 = await controller.GetDailySummary(child2, null);
        r1.Result.Should().BeOfType<OkObjectResult>();
        r2.Result.Should().BeOfType<OkObjectResult>();

        // Yabancı çocuk için 403
        SetupChildrenForParent(ParentUserId, new[] { child1, child2 }); // reset mock
        var r3 = await controller.GetDailySummary(foreignChild, null);
        r3.Result.Should().BeOfType<ForbidResult>();
    }
}
