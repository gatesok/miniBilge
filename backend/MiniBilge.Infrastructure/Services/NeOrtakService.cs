using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// "Ne Ortak?" sorularını GPT-4o-mini ile üretir.
/// 4 görünüşte alakasız ipucu → gizli ortak bağlantı.
/// Stateless — DB'ye kayıt yok.
/// </summary>
public class NeOrtakService : INeOrtakService
{
    private readonly IHttpClientFactory       _http;
    private readonly ILogger<NeOrtakService>  _logger;

    public NeOrtakService(
        IHttpClientFactory       http,
        ILogger<NeOrtakService>  logger)
    {
        _http   = http;
        _logger = logger;
    }

    public async Task<List<NeOrtakQuestionDto>> GenerateAsync(GenerateNeOrtakRequest req)
    {
        var prompt = BuildPrompt(req);
        var raw    = await CallGptAsync(prompt);

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
            _logger.LogError(ex, "[NeOrtak] GPT parse hatası. Raw: {Raw}", raw);
            return [];
        }
    }

    // ── Prompt ───────────────────────────────────────────────────────────────

    private static string BuildPrompt(GenerateNeOrtakRequest req)
    {
        string difficultyTr, rules;
        switch (req.Difficulty)
        {
            case "Kolay":
                difficultyTr = "KOLAY";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- The connection must be immediately recognizable to most adults.\n" +
                    "- Use well-known brands, colors, animals, countries, or famous characters.\n" +
                    "- Example: Clues=[\"Kırmızı\", \"Beyaz\", \"Siyah\", \"Mavi\"] → Connection=\"Renk\"\n" +
                    "- Example: Clues=[\"Hollywood\", \"Kutup Ayısı\", \"Noel\", \"Coca-Cola\"] → Connection=\"Kırmızı-Beyaz\"\n" +
                    "- Wrong options should be clearly different from the connection.\n" +
                    "- A child or teenager should guess correctly.";
                break;

            case "Zor":
                difficultyTr = "ZOR";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- The connection must be non-obvious and require lateral thinking.\n" +
                    "- Clues should seem completely unrelated at first glance.\n" +
                    "- Use abstract, counter-intuitive, or niche cultural connections.\n" +
                    "- Example: Clues=[\"Leonardo\", \"Michelangelo\", \"Donatello\", \"Raphael\"] → Connection=\"Ninja Kaplumbağalar / Rönesans Sanatçıları\"\n" +
                    "- Even educated adults should find these challenging.\n" +
                    "- Wrong options should be very plausible confusers.";
                break;

            default: // Orta
                difficultyTr = "ORTA";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- The connection requires some thought but is reachable with knowledge.\n" +
                    "- Mix of pop culture, history, science, geography, and language connections.\n" +
                    "- Example: Clues=[\"Titanic\", \"Avatar\", \"Aliens\", \"Terminator\"] → Connection=\"James Cameron Filmleri\"\n" +
                    "- A culturally aware adult should guess by thinking 10-20 seconds.\n" +
                    "- Wrong options should be plausible but distinguishable.";
                break;
        }

        var forbidden = req.ForbiddenConnections.Count > 0
            ? "⛔ STRICT REPETITION RULE — These connections have ALREADY been shown to this user.\n" +
              "Do NOT use them and do NOT use connections from the same narrow sub-category:\n" +
              string.Join("\n", req.ForbiddenConnections.TakeLast(20).Select(c => $"  - {c}"))
            : string.Empty;

        // Kategori çeşitliliği için günlük seed ile karıştırılmış liste
        var rng        = new Random(DateTime.UtcNow.DayOfYear + req.Difficulty.Length * 7);
        var categories = new[]
        {
            "bir marka veya şirket",
            "bir ünlü kişi adı (takma ad, soyad veya lakap)",
            "bir renk veya sayı",
            "bir film, dizi veya kitap serisi",
            "bir bilimsel kavram veya tarihî olay",
            "bir spor veya oyun terimi",
            "coğrafya (ülke, şehir, yer adı)",
            "bir dil oyunu (çift anlam, eşseslilik, kısaltma)",
            "bir kültürel sembol veya mitoloji",
            "bir hayvan veya doğa kavramı",
        };
        var shuffled     = categories.OrderBy(_ => rng.Next()).Take(5).ToArray();
        var categoryList = string.Join("; ", shuffled.Select((c, i) => $"Soru {i + 1}: {c}"));

        var date = req.DateSeed ?? DateTime.UtcNow.ToString("d MMMM yyyy");

        return $$"""
You are a Turkish "Ne Ortak?" (What do these have in common?) quiz generator. ALL text must be in Turkish.

Generate EXACTLY 5 questions. Each question has 4 clues that seem unrelated but share a hidden connection.
Use this category order (one per question): {{categoryList}}

DIFFICULTY: {{difficultyTr}}
Date context: {{date}}

{{rules}}

{{(forbidden.Length > 0 ? forbidden + "\n\n" : "")}}Rules for clues:
- EXACTLY 4 clues per question.
- Clues must seem unrelated at first glance.
- ALL clues must genuinely relate to the connection — no misleading clues.
- Clues should be single words or very short phrases (max 3 words each).
- Do NOT include the connection word inside any clue.

Rules for options:
- EXACTLY 4 options including the correct answer (= the connection).
- Options must be concise (1-4 words).
- Wrong options should be in the same general domain as the connection.
- Shuffle the correct answer position (not always first).

Rules for explanation:
- 1-2 Turkish sentences explaining WHY each clue connects to the answer.
- Keep it educational and interesting.

VARIETY: Make each question's connection theme completely different from the others. No two questions should share a broad category.

Return ONLY valid JSON, no other text:
{
  "questions": [
    {
      "clues": ["ipucu1", "ipucu2", "ipucu3", "ipucu4"],
      "connection": "gizli bağlantı",
      "options": ["A şıkkı", "B şıkkı", "C şıkkı", "D şıkkı"],
      "correctAnswer": "doğru cevap (options'tan biri)",
      "explanation": "kısa açıklama"
    }
  ]
}
""";
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static NeOrtakQuestionDto ParseQuestion(JsonElement el)
    {
        string Get(string key) =>
            el.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        List<string> GetList(string key)
        {
            if (!el.TryGetProperty(key, out var arr)) return [];
            return arr.EnumerateArray().Select(x => x.GetString() ?? "").ToList();
        }

        return new NeOrtakQuestionDto
        {
            Clues         = GetList("clues"),
            Connection    = Get("connection"),
            Options       = GetList("options"),
            CorrectAnswer = Get("correctAnswer"),
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
                new { role = "system", content = "Sen Türkçe 'Ne Ortak?' oyunu için sorular üretiyorsun. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = prompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 1200,   // 5 soru için yeterli
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
