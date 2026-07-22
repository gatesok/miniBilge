using FluentAssertions;
using Microsoft.AspNetCore.Http;
using MiniBilge.API.Middleware;

namespace MiniBilge.Tests.Integration;

public sealed class CorrelationIdMiddlewareTests
{
    [Fact]
    public async Task InvokeAsync_WithValidIncomingId_PreservesIdAcrossRequestAndResponse()
    {
        const string correlationId = "mobile-request_123";
        var context = new DefaultHttpContext();
        context.Request.Headers[CorrelationIdMiddleware.HeaderName] = correlationId;
        string? idSeenByNext = null;
        var middleware = new CorrelationIdMiddleware(nextContext =>
        {
            idSeenByNext = nextContext.Items[CorrelationIdMiddleware.ItemKey]?.ToString();
            return Task.CompletedTask;
        });

        await middleware.InvokeAsync(context);

        idSeenByNext.Should().Be(correlationId);
        context.Response.Headers[CorrelationIdMiddleware.HeaderName]
            .ToString().Should().Be(correlationId);
    }

    [Theory]
    [InlineData("contains space")]
    [InlineData("contains!symbol")]
    [InlineData("aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")]
    public async Task InvokeAsync_WithUnsafeIncomingId_ReplacesIt(string unsafeId)
    {
        var context = new DefaultHttpContext();
        context.Request.Headers[CorrelationIdMiddleware.HeaderName] = unsafeId;
        var middleware = new CorrelationIdMiddleware(_ => Task.CompletedTask);

        await middleware.InvokeAsync(context);

        var generated = context.Response.Headers[CorrelationIdMiddleware.HeaderName].ToString();
        generated.Should().NotBe(unsafeId);
        generated.Should().MatchRegex("^[a-f0-9]{32}$");
    }
}
