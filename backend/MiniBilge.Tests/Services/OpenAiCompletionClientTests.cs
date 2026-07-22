using System.Net;
using System.Text;
using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging.Abstractions;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Options;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.Tests.Services;

public sealed class OpenAiCompletionClientTests
{
    [Fact]
    public async Task CompleteJsonAsync_TracksTokensDurationAndCost()
    {
        await using var db = CreateDbContext();
        var response = """
        {
          "model": "gpt-4o-mini-test",
          "choices": [{"message":{"content":"{\"ok\":true}"}}],
          "usage": {"prompt_tokens":1000,"completion_tokens":500}
        }
        """;
        var sut = CreateClient(db, HttpStatusCode.OK, response);

        var result = await sut.CompleteJsonAsync(
            "adaptive_quiz_generate", "system", "user", 100, 0.7, Guid.NewGuid());

        result.Should().Be("{\"ok\":true}");
        var usage = await db.AiUsageEvents.SingleAsync();
        usage.Success.Should().BeTrue();
        usage.FeatureKey.Should().Be("adaptive_quiz_generate");
        usage.Model.Should().Be("gpt-4o-mini-test");
        usage.InputTokens.Should().Be(1000);
        usage.OutputTokens.Should().Be(500);
        usage.EstimatedCostUsd.Should().Be(0.00045m);
        usage.DurationMs.Should().BeGreaterThanOrEqualTo(0);
    }

    [Fact]
    public async Task CompleteJsonAsync_TracksProviderFailureWithoutResponseBody()
    {
        await using var db = CreateDbContext();
        var sut = CreateClient(db, HttpStatusCode.TooManyRequests, "secret provider detail");

        var action = () => sut.CompleteJsonAsync(
            "writing_evaluate", "system", "private student text", 100, 0.7);

        await action.Should().ThrowAsync<HttpRequestException>();
        var usage = await db.AiUsageEvents.SingleAsync();
        usage.Success.Should().BeFalse();
        usage.ErrorCode.Should().Be("provider_429");
        usage.Should().NotBeNull();
    }

    private static OpenAiCompletionClient CreateClient(
        ApplicationDbContext db,
        HttpStatusCode statusCode,
        string responseBody)
    {
        var httpClient = new HttpClient(new StubHandler(statusCode, responseBody))
        {
            BaseAddress = new Uri("https://example.test/v1/")
        };
        var factory = new StubHttpClientFactory(httpClient);
        var options = Options.Create(new OpenAiSettings
        {
            Model = "gpt-4o-mini",
            InputCostPerMillionTokensUsd = 0.15m,
            OutputCostPerMillionTokensUsd = 0.60m,
        });

        return new OpenAiCompletionClient(
            factory,
            db,
            options,
            NullLogger<OpenAiCompletionClient>.Instance);
    }

    private static ApplicationDbContext CreateDbContext()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(Guid.NewGuid().ToString())
            .Options;
        return new ApplicationDbContext(options);
    }

    private sealed class StubHttpClientFactory(HttpClient client) : IHttpClientFactory
    {
        public HttpClient CreateClient(string name) => client;
    }

    private sealed class StubHandler(HttpStatusCode statusCode, string body) : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            return Task.FromResult(new HttpResponseMessage(statusCode)
            {
                Content = new StringContent(body, Encoding.UTF8, "application/json")
            });
        }
    }
}
