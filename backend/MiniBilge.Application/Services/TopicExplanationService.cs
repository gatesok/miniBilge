using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.Application.Services;

/// <summary>
/// GPT-4o-mini kullanarak İngilizce konu anlatımı üretir.
/// 6-12 yaş çocuklara yönelik; Türkçe açıklama + İngilizce örnekler.
/// </summary>
public class TopicExplanationService : ITopicExplanationService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly ILogger<TopicExplanationService> _logger;

    public TopicExplanationService(
        IHttpClientFactory httpClientFactory,
        ILogger<TopicExplanationService> logger)
    {
        _httpClientFactory = httpClientFactory;
        _logger = logger;
    }

    public async Task<TopicExplanationDto> ExplainTopicAsync(ExplainTopicRequest request)
    {
        var wrongSection = request.WrongTopics.Count > 0
            ? $"The student made mistakes related to: {string.Join(", ", request.WrongTopics)}. Focus on these areas."
            : string.Empty;

        var system =
            "You are a friendly English teacher for Turkish children aged 6-12. " +
            "Always explain grammar rules in simple Turkish, then give English examples. " +
            "Keep explanations very short, clear, and encouraging.";

        var user =
            $"Explain the English topic '{request.SubjectName}' for a CEFR {request.Level} student. " +
            $"{wrongSection} " +
            "Return a JSON object with these exact keys: " +
            "\"rule\" (string — 1-2 sentence Turkish explanation), " +
            "\"examples\" (array of 3 English example sentences), " +
            "\"commonMistakes\" (array of 2 short Turkish strings describing common errors), " +
            "\"tip\" (string — 1 short encouraging Turkish tip).";

        try
        {
            var raw = await CallGptAsync(system, user);
            using var doc = JsonDocument.Parse(raw);
            var root = doc.RootElement;

            return new TopicExplanationDto
            {
                Rule = root.GetProperty("rule").GetString() ?? string.Empty,
                Examples = root.GetProperty("examples")
                    .EnumerateArray()
                    .Select(e => e.GetString() ?? string.Empty)
                    .ToList(),
                CommonMistakes = root.GetProperty("commonMistakes")
                    .EnumerateArray()
                    .Select(e => e.GetString() ?? string.Empty)
                    .ToList(),
                Tip = root.GetProperty("tip").GetString() ?? string.Empty,
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Konu anlatımı üretilirken hata: {Topic}", request.SubjectName);
            return FallbackExplanation(request.SubjectName);
        }
    }

    private async Task<string> CallGptAsync(string systemPrompt, string userPrompt)
    {
        var client = _httpClientFactory.CreateClient("openai");

        var body = new
        {
            model = "gpt-4o-mini",
            messages = new[]
            {
                new { role = "system", content = systemPrompt },
                new { role = "user",   content = userPrompt   },
            },
            response_format = new { type = "json_object" },
            max_tokens  = 600,
            temperature = 0.5,
        };

        var json     = JsonSerializer.Serialize(body);
        var content  = new StringContent(json, Encoding.UTF8, "application/json");
        var response = await client.PostAsync("chat/completions", content);
        response.EnsureSuccessStatusCode();

        var responseJson = await response.Content.ReadAsStringAsync();
        using var doc    = JsonDocument.Parse(responseJson);
        return doc.RootElement
                  .GetProperty("choices")[0]
                  .GetProperty("message")
                  .GetProperty("content")
                  .GetString() ?? "{}";
    }

    private static TopicExplanationDto FallbackExplanation(string subject) => new()
    {
        Rule = $"'{subject}' konusunu tekrar çalışmanı öneririm.",
        Examples = ["Practice makes perfect!", "Keep trying!", "You can do it!"],
        CommonMistakes = ["Kuralı ezberlemek yerine örneklerle öğren.", "Alıştırma yapmayı unutma."],
        Tip = "Her gün birkaç dakika İngilizce pratik yap! 💪",
    };
}
