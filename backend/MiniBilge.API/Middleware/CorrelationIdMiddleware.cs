using Serilog.Context;
using System.Diagnostics;

namespace MiniBilge.API.Middleware;

public sealed class CorrelationIdMiddleware
{
    public const string HeaderName = "X-Correlation-ID";
    public const string ItemKey = "CorrelationId";
    private const int MaxLength = 64;

    private readonly RequestDelegate _next;

    public CorrelationIdMiddleware(RequestDelegate next)
    {
        _next = next;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = GetOrCreateCorrelationId(context.Request.Headers[HeaderName].FirstOrDefault());
        context.Items[ItemKey] = correlationId;
        context.Response.Headers[HeaderName] = correlationId;
        Activity.Current?.SetTag(ItemKey, correlationId);

        using (LogContext.PushProperty(ItemKey, correlationId))
        {
            await _next(context);
        }
    }

    private static string GetOrCreateCorrelationId(string? candidate)
    {
        if (!string.IsNullOrWhiteSpace(candidate) &&
            candidate.Length <= MaxLength &&
            candidate.All(character => char.IsLetterOrDigit(character) || character is '-' or '_'))
        {
            return candidate;
        }

        return Guid.NewGuid().ToString("N");
    }
}
