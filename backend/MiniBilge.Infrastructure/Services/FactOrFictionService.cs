using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// "Gerçek mi Uydurma mı?" ifadelerini GPT-4o-mini ile üretir.
/// Stateless — DB'ye kayıt yok. Tekrar önleme: istek içinde gelen ForbiddenStatements prompt'a eklenir.
/// </summary>
public class FactOrFictionService : IFactOrFictionService
{
    private readonly IHttpClientFactory            _http;
    private readonly ILogger<FactOrFictionService> _logger;

    public FactOrFictionService(
        IHttpClientFactory            http,
        ILogger<FactOrFictionService> logger)
    {
        _http   = http;
        _logger = logger;
    }

    public async Task<List<FactOrFictionQuestionDto>> GenerateAsync(GenerateFactOrFictionRequest req)
    {
        var prompt = BuildPrompt(req);
        var raw    = await CallGptAsync(prompt);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            return doc.RootElement
                .GetProperty("items")
                .EnumerateArray()
                .Select(ParseItem)
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[FactOrFiction] GPT parse hatası. Raw: {Raw}", raw);
            return [];
        }
    }

    // ── Prompt ───────────────────────────────────────────────────────────────

    private static string BuildPrompt(GenerateFactOrFictionRequest req)
    {
        string difficultyTr, rules;
        switch (req.Difficulty)
        {
            case "Kolay":
                difficultyTr = "KOLAY";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Statements must be about everyday life, popular culture, well-known history.\n" +
                    "- Real facts should be surprising but easy to verify with common knowledge.\n" +
                    "- Fake statements should sound plausible but be clearly wrong to most people.\n" +
                    "- Example real: 'Zürafalar uyumak için uzanmak zorunda değildir.' (gerçek)\n" +
                    "- Example fake: 'Dünyada en çok konuşulan dil İspanyolcadır.' (uydurma — Mandarin)\n" +
                    "- Keep the language simple and accessible.";
                break;

            case "Zor":
                difficultyTr = "ZOR";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Real facts must be highly counter-intuitive — things most people would assume are false.\n" +
                    "- Fake statements must sound like expert-level facts that are hard to disprove without research.\n" +
                    "- Include specific numbers, dates, scientific terms to make fakes more convincing.\n" +
                    "- Example real: 'Bal arıları karar vermek için oy kullanır.' (gerçek)\n" +
                    "- Example fake: 'İnsan beyni ömür boyu yalnızca %10 kapasitesiyle çalışır.' (uydurma)\n" +
                    "- Even educated adults should find these genuinely challenging.";
                break;

            default: // Orta
                difficultyTr = "ORTA";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Mix of well-known facts that seem fake and plausible-sounding false statements.\n" +
                    "- Real facts should be genuinely interesting and somewhat surprising.\n" +
                    "- Fake statements should require some knowledge to disprove.\n" +
                    "- Topics: science, history, geography, nature, sports, technology.\n" +
                    "- Example real: 'Ahtapotların üç kalbi vardır.' (gerçek)\n" +
                    "- Example fake: 'Çin Seddi uzaydan çıplak gözle görülebilir.' (uydurma)";
                break;
        }

        var forbidden = req.ForbiddenStatements.Count > 0
            ? "⛔ STRICT RULE — The following statements have ALREADY been shown to this user.\n" +
              "You MUST NOT generate these statements OR any statement on the SAME TOPIC/FACT.\n" +
              "Even a paraphrase of these is forbidden:\n" +
              string.Join("\n", req.ForbiddenStatements.TakeLast(15).Select(s => $"  - {s}"))
            : string.Empty;

        var date = req.DateSeed ?? DateTime.UtcNow.ToString("d MMMM yyyy");

        return $$"""
You are a "Gerçek mi Uydurma mı?" (Real or Fake?) game generator. ALL text must be in Turkish.

Generate EXACTLY 10 statements. Aim for roughly 5 real and 5 fake (slight variation is OK).
DIFFICULTY: {{difficultyTr}}
Date context: {{date}}

{{rules}}

{{(forbidden.Length > 0 ? forbidden + "\n\n" : "")}}Additional rules:
- Every statement must be a single, clear, declarative sentence in Turkish.
- Statements must cover VARIED topics — do not repeat the same topic twice.
- Keep statements concise (max 20 words).
- Explanations must be brief (1-2 sentences) and educational.
- For fake statements, the explanation must state what the real fact actually is.
- GENERATE EXACTLY 10 ITEMS.

Return ONLY valid JSON, no other text:
{
  "items": [
    {
      "statement": "ifade metni",
      "isReal": true,
      "explanation": "kısa açıklama"
    }
  ]
}
""";
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static FactOrFictionQuestionDto ParseItem(JsonElement el)
    {
        string Get(string key) =>
            el.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        bool isReal = false;
        if (el.TryGetProperty("isReal", out var boolProp))
            isReal = boolProp.ValueKind == JsonValueKind.True;

        return new FactOrFictionQuestionDto
        {
            Statement   = Get("statement"),
            IsReal      = isReal,
            Explanation = Get("explanation"),
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
                new { role = "system", content = "Sen Türkçe 'Gerçek mi Uydurma mı?' oyunu için ifadeler üretiyorsun. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = prompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 1500,
            temperature     = 0.9,
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
