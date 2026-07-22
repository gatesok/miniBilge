using System.Diagnostics;
using System.Net;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public sealed class OpenAiCompletionClient : IOpenAiCompletionClient
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ApplicationDbContext _dbContext;
    private readonly OpenAiSettings _settings;
    private readonly ILogger<OpenAiCompletionClient> _logger;

    public OpenAiCompletionClient(
        IHttpClientFactory httpClientFactory,
        ApplicationDbContext dbContext,
        IOptions<OpenAiSettings> settings,
        ILogger<OpenAiCompletionClient> logger)
    {
        _httpClientFactory = httpClientFactory;
        _dbContext = dbContext;
        _settings = settings.Value;
        _logger = logger;
    }

    public async Task<string> CompleteJsonAsync(
        string featureKey,
        string systemPrompt,
        string userPrompt,
        int maxTokens,
        double temperature,
        Guid? childProfileId = null,
        CancellationToken cancellationToken = default)
    {
        var stopwatch = Stopwatch.StartNew();
        string? responseJson = null;
        HttpStatusCode? statusCode = null;

        try
        {
            var client = _httpClientFactory.CreateClient("openai");
            var body = new
            {
                model = _settings.Model,
                messages = new[]
                {
                    new { role = "system", content = systemPrompt },
                    new { role = "user", content = userPrompt },
                },
                response_format = new { type = "json_object" },
                max_tokens = maxTokens,
                temperature,
            };

            using var content = new StringContent(
                JsonSerializer.Serialize(body), Encoding.UTF8, "application/json");
            using var response = await client.PostAsync(
                "chat/completions", content, cancellationToken);
            statusCode = response.StatusCode;
            responseJson = await response.Content.ReadAsStringAsync(cancellationToken);
            response.EnsureSuccessStatusCode();

            using var document = JsonDocument.Parse(responseJson);
            var root = document.RootElement;
            var model = root.TryGetProperty("model", out var modelElement)
                ? modelElement.GetString() ?? _settings.Model
                : _settings.Model;
            var (inputTokens, outputTokens) = ReadUsage(root);

            await TrackBestEffortAsync(new AiUsageEvent
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                FeatureKey = featureKey,
                Provider = "openai",
                Model = model,
                InputTokens = inputTokens,
                OutputTokens = outputTokens,
                EstimatedCostUsd = CalculateCost(inputTokens, outputTokens),
                DurationMs = stopwatch.ElapsedMilliseconds,
                Success = true,
                CorrelationId = GetCorrelationId(),
            }, cancellationToken);

            return root.GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString() ?? "{}";
        }
        catch (Exception exception)
        {
            await TrackBestEffortAsync(new AiUsageEvent
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                FeatureKey = featureKey,
                Provider = "openai",
                Model = _settings.Model,
                DurationMs = stopwatch.ElapsedMilliseconds,
                Success = false,
                ErrorCode = ClassifyError(exception, statusCode),
                CorrelationId = GetCorrelationId(),
            }, cancellationToken);
            throw;
        }
    }

    private static (int? InputTokens, int? OutputTokens) ReadUsage(JsonElement root)
    {
        if (!root.TryGetProperty("usage", out var usage))
            return (null, null);

        int? input = usage.TryGetProperty("prompt_tokens", out var promptTokens)
            ? promptTokens.GetInt32()
            : null;
        int? output = usage.TryGetProperty("completion_tokens", out var completionTokens)
            ? completionTokens.GetInt32()
            : null;
        return (input, output);
    }

    private decimal? CalculateCost(int? inputTokens, int? outputTokens)
    {
        if (!inputTokens.HasValue || !outputTokens.HasValue ||
            !_settings.InputCostPerMillionTokensUsd.HasValue ||
            !_settings.OutputCostPerMillionTokensUsd.HasValue)
        {
            return null;
        }

        return decimal.Round(
            inputTokens.Value / 1_000_000m * _settings.InputCostPerMillionTokensUsd.Value +
            outputTokens.Value / 1_000_000m * _settings.OutputCostPerMillionTokensUsd.Value,
            8,
            MidpointRounding.AwayFromZero);
    }

    private async Task TrackBestEffortAsync(
        AiUsageEvent usageEvent,
        CancellationToken cancellationToken)
    {
        try
        {
            _dbContext.AiUsageEvents.Add(usageEvent);
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (Exception exception)
        {
            _dbContext.Entry(usageEvent).State = Microsoft.EntityFrameworkCore.EntityState.Detached;
            _logger.LogWarning(
                exception,
                "AI usage tracking failed. Feature={FeatureKey} CorrelationId={CorrelationId}",
                usageEvent.FeatureKey,
                usageEvent.CorrelationId);
        }
    }

    private static string? GetCorrelationId() =>
        Activity.Current?.GetTagItem("CorrelationId")?.ToString()
        ?? Activity.Current?.TraceId.ToString();

    private static string ClassifyError(Exception exception, HttpStatusCode? statusCode)
    {
        if (exception is OperationCanceledException)
            return "timeout_or_cancelled";
        if (statusCode.HasValue)
            return $"provider_{(int)statusCode.Value}";
        if (exception is JsonException)
            return "invalid_provider_json";
        if (exception is HttpRequestException)
            return "provider_network_error";
        return "internal_error";
    }
}
