using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// "Kim Bu?" turlarını GPT-4o-mini ile üretir.
/// Her turda 5 konu; her konuda 5 sıralı ipucu + 4 çoktan seçmeli şık.
/// Stateless — DB'ye kayıt yok.
/// </summary>
public class KimBuService : IKimBuService
{
    private readonly IHttpClientFactory        _http;
    private readonly ILogger<KimBuService>     _logger;

    public KimBuService(
        IHttpClientFactory        http,
        ILogger<KimBuService>     logger)
    {
        _http   = http;
        _logger = logger;
    }

    public async Task<KimBuRoundDto> GenerateAsync(GenerateKimBuRequest req)
    {
        var prompt = BuildPrompt(req);
        var raw    = await CallGptAsync(prompt);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            var subjects  = doc.RootElement
                .GetProperty("subjects")
                .EnumerateArray()
                .Select(ParseSubject)
                .ToList();

            return new KimBuRoundDto { Subjects = subjects };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[KimBu] GPT parse hatası. Raw: {Raw}", raw);
            return new KimBuRoundDto();
        }
    }

    // ── Prompt ───────────────────────────────────────────────────────────────

    private static string BuildPrompt(GenerateKimBuRequest req)
    {
        string difficultyTr, rules;
        switch (req.Difficulty)
        {
            case "Kolay":
                difficultyTr = "KOLAY";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Subjects must be VERY FAMOUS — mega-popular in Turkey and globally.\n" +
                    "- Examples: Atatürk, Messi, Taylor Swift, Netflix, iPhone, İstanbul.\n" +
                    "- Even a teenager should be able to guess with 3 hints.\n" +
                    "- Hint 1 is vague but not misleading; Hint 5 is almost the answer.\n" +
                    "- Wrong options should be in the same category but clearly different.";
                break;

            case "Zor":
                difficultyTr = "ZOR";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Subjects should require knowledge beyond everyday culture.\n" +
                    "- Examples: historical figures, scientific discoveries, niche brands, ancient events.\n" +
                    "- A knowledgeable adult may need all 5 hints.\n" +
                    "- Hint 1 must be very indirect; only Hint 4-5 should narrow it clearly.\n" +
                    "- Wrong options should be plausible confusers in the same category.";
                break;

            default: // Orta
                difficultyTr = "ORTA";
                rules =
                    "DIFFICULTY RULES:\n" +
                    "- Subjects should be well-known but require some thought.\n" +
                    "- Mix of current celebrities, historical figures, brands, movies, places.\n" +
                    "- An educated adult should guess correctly by hint 3-4.\n" +
                    "- Hint 1 is cryptic; Hints 4-5 are quite revealing.\n" +
                    "- Wrong options should be believable alternatives in the same domain.";
                break;
        }

        var forbidden = req.ForbiddenSubjects.Count > 0
            ? "⛔ STRICT REPETITION RULE — This user has already seen ALL of these subjects.\n" +
              "Do NOT use them, do NOT use paraphrases, do NOT use subjects in the same narrow sub-category.\n" +
              "For example: if 'Atatürk' is forbidden, do NOT use other Turkish founding figures as subjects.\n" +
              "If 'Titanic (film)' is forbidden, do NOT use other James Cameron films.\n" +
              "Forbidden list:\n" +
              string.Join("\n", req.ForbiddenSubjects.TakeLast(20).Select(s => $"  - {s}"))
            : string.Empty;

        // Rastgele kategori sıralaması için tarih tabanlı seed
        // 10 konu → her 5 kategoriden 2'şer adet, farklı sırayla
        var rng        = new Random(DateTime.UtcNow.DayOfYear + req.Difficulty.Length);
        var categories = new[] { "bir kişi (ünlü, sporcu veya tarihî figür)", "bir film veya dizi", "bir marka veya şirket", "bir yer (şehir, ülke veya coğrafî alan)", "tarihî bir olay veya buluş" };
        var shuffled   = categories.OrderBy(_ => rng.Next()).ToArray();
        // Her kategoriyi 2 kez ekle, ikinci seti de farklı sırayla karıştır
        var secondSet  = categories.OrderBy(_ => rng.Next()).ToArray();
        var categoryList = string.Join(", ", shuffled.Concat(secondSet));

        var date = req.DateSeed ?? DateTime.UtcNow.ToString("d MMMM yyyy");

        return $$"""
You are a Turkish "Kim Bu?" (Who/What is it?) quiz generator. ALL text must be in Turkish.

Generate EXACTLY 10 subjects. Use EXACTLY these 10 categories (one subject per category, in this order): {{categoryList}}.
This category rotation ensures variety across games — each category appears twice but with DIFFERENT subjects.

DIFFICULTY: {{difficultyTr}}
Date context: {{date}}

{{rules}}

{{(forbidden.Length > 0 ? forbidden + "\n\n" : "")}}Variety rules (CRITICAL):
- Choose UNEXPECTED, CREATIVE subjects — not the first famous name that comes to mind.
- Avoid overused examples: do NOT use Atatürk, Messi, Taylor Swift, Steve Jobs, Apple, or Titanic unless there is absolutely no alternative.
- Think of subjects that are well-known but less frequently guessed — surprising choices are better.
- Each subject must be from a DIFFERENT era or domain than the others.

Rules for hints:
- EXACTLY 5 hints per subject, ordered from MOST VAGUE to MOST SPECIFIC.
- Each hint is a single Turkish sentence, max 15 words.
- Hint 5 should make the answer obvious; Hint 1 should give almost nothing away.
- Do NOT mention the subject name in any hint.
- Hints must be factually correct.

Rules for options:
- EXACTLY 4 options including the correct answer.
- Options must be in Turkish (names stay as-is, but descriptions in Turkish).
- Wrong options must be plausible — same category as the correct answer.
- Shuffle the position of the correct answer (don't always put it first).

Return ONLY valid JSON, no other text:
{
  "subjects": [
    {
      "subject": "konu adı (Türkçe)",
      "hints": [
        "1. ipucu (en muğlak)",
        "2. ipucu",
        "3. ipucu",
        "4. ipucu",
        "5. ipucu (en açık)"
      ],
      "options": ["A şıkkı", "B şıkkı", "C şıkkı", "D şıkkı"],
      "correctAnswer": "doğru cevap (options listesinden biri)"
    }
  ]
}
""";
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static KimBuSubjectDto ParseSubject(JsonElement el)
    {
        string Get(string key) =>
            el.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        List<string> GetList(string key)
        {
            if (!el.TryGetProperty(key, out var arr)) return [];
            return arr.EnumerateArray()
                      .Select(x => x.GetString() ?? "")
                      .ToList();
        }

        return new KimBuSubjectDto
        {
            Subject       = Get("subject"),
            Hints         = GetList("hints"),
            Options       = GetList("options"),
            CorrectAnswer = Get("correctAnswer"),
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
                new { role = "system", content = "Sen Türkçe 'Kim Bu?' oyunu için sorular üretiyorsun. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = prompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 3500,   // 10 konu × (5 ipucu + 4 şık) için güvenli
            temperature     = 0.85,
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
