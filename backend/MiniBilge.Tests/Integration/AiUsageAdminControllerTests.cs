using FluentAssertions;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using MiniBilge.API.Controllers;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Tests.Integration;

public sealed class AiUsageAdminControllerTests
{
    private const string AdminKey = "test-admin-key";

    [Fact]
    public async Task GetSummary_WithoutAdminKey_ReturnsUnauthorized()
    {
        await using var db = CreateDbContext();
        var controller = CreateController(db, includeAdminHeader: false);

        var result = await controller.GetSummary(null, null, CancellationToken.None);

        result.Result.Should().BeOfType<UnauthorizedResult>();
    }

    [Fact]
    public async Task GetSummary_WithMoreThan31Days_ReturnsBadRequest()
    {
        await using var db = CreateDbContext();
        var controller = CreateController(db);
        var today = DateOnly.FromDateTime(DateTime.UtcNow);

        var result = await controller.GetSummary(
            today.AddDays(-31),
            today,
            CancellationToken.None);

        result.Result.Should().BeOfType<BadRequestObjectResult>();
    }

    [Fact]
    public async Task GetSummary_GroupsUsageWithoutReturningProfileIdentifiers()
    {
        await using var db = CreateDbContext();
        db.AiUsageEvents.AddRange(
            CreateEvent("adaptive_quiz_generate", true, 100, 50, 0.000045m, 120),
            CreateEvent("adaptive_quiz_generate", false, null, null, null, 80),
            CreateEvent("writing_evaluate", true, 200, 75, 0.000075m, 300));
        await db.SaveChangesAsync();
        var controller = CreateController(db);

        var result = await controller.GetSummary(null, null, CancellationToken.None);

        var ok = result.Result.Should().BeOfType<OkObjectResult>().Subject;
        var response = ok.Value.Should().BeOfType<AiUsageSummaryResponse>().Subject;
        response.Rows.Should().HaveCount(2);

        var adaptive = response.Rows.Single(x =>
            x.FeatureKey == "adaptive_quiz_generate");
        adaptive.RequestCount.Should().Be(2);
        adaptive.SuccessCount.Should().Be(1);
        adaptive.FailureCount.Should().Be(1);
        adaptive.InputTokens.Should().Be(100);
        adaptive.OutputTokens.Should().Be(50);
        adaptive.EstimatedCostUsd.Should().Be(0.000045m);
        adaptive.TotalDurationMs.Should().Be(200);
    }

    private static AiUsageEvent CreateEvent(
        string feature,
        bool success,
        int? inputTokens,
        int? outputTokens,
        decimal? cost,
        long durationMs) => new()
    {
        Id = Guid.NewGuid(),
        ChildProfileId = Guid.NewGuid(),
        FeatureKey = feature,
        Provider = "openai",
        Model = "gpt-4o-mini",
        InputTokens = inputTokens,
        OutputTokens = outputTokens,
        EstimatedCostUsd = cost,
        DurationMs = durationMs,
        Success = success,
        ErrorCode = success ? null : "provider_500"
    };

    private static ApplicationDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    private static AiUsageAdminController CreateController(
        ApplicationDbContext db,
        bool includeAdminHeader = true)
    {
        var configuration = new ConfigurationBuilder()
            .AddInMemoryCollection(new Dictionary<string, string?>
            {
                ["Admin:ApiKey"] = AdminKey
            })
            .Build();
        var context = new DefaultHttpContext();
        if (includeAdminHeader)
        {
            context.Request.Headers["X-Admin-Key"] = AdminKey;
        }

        return new AiUsageAdminController(db, configuration)
        {
            ControllerContext = new ControllerContext { HttpContext = context }
        };
    }
}
