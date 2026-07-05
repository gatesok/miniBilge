using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Eğlence quiz sorularını GPT-4o-mini ile stateless olarak üretir.
/// DB'ye kayıt yok — her çağrıda tamamen yeni sorular gelir.
/// Tekrar önleme: istek içinde gelen AskedQuestions listesi prompt'a eklenir.
/// </summary>
public class EntertainmentQuizService : IEntertainmentQuizService
{
    private readonly IHttpClientFactory           _http;
    private readonly ILogger<EntertainmentQuizService> _logger;

    public EntertainmentQuizService(
        IHttpClientFactory           http,
        ILogger<EntertainmentQuizService> logger)
    {
        _http   = http;
        _logger = logger;
    }

    // ── Topic Listesi ─────────────────────────────────────────────────────────

    public IReadOnlyList<EntertainmentTopicDto> GetTopics()
        => EntertainmentTopics.All
            .Select(kv => new EntertainmentTopicDto
            {
                Key   = kv.Key,
                Label = kv.Value.Label,
                Emoji = kv.Value.Emoji,
            })
            .ToList();

    // ── Soru Üretimi ─────────────────────────────────────────────────────────

    public async Task<List<EntertainmentQuestionDto>> GenerateAsync(
        GenerateEntertainmentRequest req)
    {
        if (!EntertainmentTopics.All.TryGetValue(req.TopicKey, out var config))
            throw new InvalidOperationException($"Bilinmeyen topic: {req.TopicKey}");

        // Alt kategorilerden rastgele seç (her çağrıda farklı kombinasyon)
        var subCats = PickSubCategories(config.SubCategories, req.Count);
        var prompt  = BuildPrompt(req, config, subCats);
        var raw     = await CallGptAsync(prompt);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            return doc.RootElement
                .GetProperty("questions")
                .EnumerateArray()
                .Select(ParseQuestion)
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[Entertainment] GPT parse hatası. Raw: {Raw}", raw);
            return [];
        }
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string BuildPrompt(
        GenerateEntertainmentRequest req,
        TopicConfig config,
        IReadOnlyList<string> subCategories)
    {
        // Zorluk seviyesi — çok spesifik kurallarla tanımlanmış
        string difficultyTr, difficultyRules;
        switch (req.Difficulty)
        {
            case "Kolay":
                difficultyTr = "KOLAY";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions must be SO EASY that any adult can answer without thinking hard.\n" +
                    "- Only ask about VERY FAMOUS people, records, and events everyone knows.\n" +
                    "  Good example: \"Hangi renk kırmızı kart rengidir?\", \"Fenerbahçe'nin renkleri nelerdir?\"\n" +
                    "- The correct answer must be OBVIOUS to almost anyone.\n" +
                    "- Wrong options should be clearly different from the correct answer.\n" +
                    "- Do NOT ask about specific statistics, rare dates, or obscure details.\n" +
                    "- Do NOT make trick questions — keep it fun and immediately answerable.";
                break;
            case "Zor":
                difficultyTr = "ZOR";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions must be HARD and require expert-level knowledge.\n" +
                    "- Ask about specific statistics, rare records, exact dates, or lesser-known facts.\n" +
                    "- Even knowledgeable people should find these challenging.\n" +
                    "- Wrong options should be plausible and confusing.\n" +
                    "- Ask about details that only true enthusiasts would know.";
                break;
            default:
                difficultyTr = "ORTA";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions should require SOME knowledge but not expert-level.\n" +
                    "- Ask about well-known facts that interested people would know.\n" +
                    "- Wrong options should be reasonable but distinguishable.\n" +
                    "- Balance between obvious and obscure.";
                break;
        }

        // Yasak sorular listesi (max 50 — istemci tarafından gönderilir)
        var forbidden = req.AskedQuestions.Count > 0
            ? "FORBIDDEN QUESTIONS (do NOT ask these or similar ones):\n" +
              string.Join("\n", req.AskedQuestions.Take(50).Select(q => $"  - {q}"))
            : "No previous questions to avoid.";

        var date = req.DateSeed ?? DateTime.UtcNow.ToString("d MMMM yyyy");

        return $$"""
You are a Turkish trivia quiz generator. Generate ALL questions and answers in Turkish.

IMPORTANT: You MUST generate EXACTLY {{req.Count}} questions — no more, no less.

Topic: {{config.Label}} ({{config.Emoji}})
Topic hint: {{config.SystemHint}}
Sub-categories for inspiration (try to cover different ones): {{string.Join(", ", subCategories)}}
DIFFICULTY LEVEL: {{difficultyTr}}
Date context: {{date}}

{{difficultyRules}}

{{forbidden}}

Additional rules:
- ALL text (questions and options) MUST be in Turkish
- Use varied question formats: "Hangisi doğrudur?", "Kaç yılında...?", "Kim...?", "Aşağıdakilerden hangisi...?", "Ne zaman...?"
- Make questions entertaining and educational
- Only one correct answer per question
- Add a short Turkish explanation for each correct answer
- GENERATE EXACTLY {{req.Count}} QUESTIONS IN THE JSON ARRAY

Return ONLY valid JSON, no other text:
{
  "questions": [
    {
      "questionText": "soru metni",
      "optionA": "A şıkkı",
      "optionB": "B şıkkı",
      "optionC": "C şıkkı",
      "optionD": "D şıkkı",
      "correctAnswer": "A",
      "explanation": "kısa açıklama"
    }
  ]
}
""";
    }

    private static IReadOnlyList<string> PickSubCategories(
        IReadOnlyList<string> all, int count)
    {
        // Karıştır, ilk N tanesini al
        var rng      = new Random();
        var shuffled = all.OrderBy(_ => rng.Next()).ToList();
        return shuffled.Take(Math.Min(count, shuffled.Count)).ToList();
    }

    private static EntertainmentQuestionDto ParseQuestion(JsonElement q)
    {
        string Get(string key) =>
            q.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        return new EntertainmentQuestionDto
        {
            QuestionText  = Get("questionText"),
            OptionA       = Get("optionA"),
            OptionB       = Get("optionB"),
            OptionC       = Get("optionC"),
            OptionD       = Get("optionD"),
            CorrectAnswer = Get("correctAnswer").ToUpper(),
            Explanation   = Get("explanation"),
        };
    }

    private async Task<string> CallGptAsync(string prompt)
    {
        var client = _http.CreateClient("openai");

        var body = new
        {
            model           = "gpt-4o-mini",
            messages        = new[]
            {
                new { role = "system", content = "Sen eğlenceli Türkçe quiz soruları üretiyorsun. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = prompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 1200,
            temperature     = 1.0,  // Maksimum çeşitlilik
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
}
