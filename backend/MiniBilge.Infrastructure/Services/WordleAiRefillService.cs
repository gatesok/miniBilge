using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Kelime havuzunu AI ile otomatik doldurur.
/// Tekrar önleme: DB'deki tüm mevcut kelimeler GPT prompt'una gönderilir.
/// </summary>
public class WordleAiRefillService : IWordleAiRefillService
{
    private readonly ApplicationDbContext          _db;
    private readonly IHttpClientFactory            _http;
    private readonly ILogger<WordleAiRefillService> _logger;

    public WordleAiRefillService(
        ApplicationDbContext          db,
        IHttpClientFactory            http,
        ILogger<WordleAiRefillService> logger)
    {
        _db     = db;
        _http   = http;
        _logger = logger;
    }

    public async Task RefillIfNeededAsync(string language = "tr", int threshold = 30)
    {
        var unusedCount = await _db.WordPool
            .CountAsync(w => w.Language == language && w.UsedOn == null && !w.IsDeleted);

        if (unusedCount < threshold)
        {
            _logger.LogInformation(
                "[Wordle] Havuzda {Count} kullanılmamış kelime kaldı (eşik: {Threshold}). AI dolumu tetikleniyor.",
                unusedCount, threshold);
            await RefillAsync(language);
        }
    }

    public async Task<int> RefillAsync(string language = "tr", int count = 20)
    {
        // 1. Mevcut tüm kelimeleri çek → GPT'ye forbidden olarak gönder
        var existingWords = await _db.WordPool
            .Where(w => w.Language == language && !w.IsDeleted)
            .Select(w => w.Word)
            .ToListAsync();

        var prompt = BuildPrompt(language, count, existingWords);
        var raw    = await CallGptAsync(prompt);

        List<GeneratedWord> generated;
        try
        {
            using var doc = JsonDocument.Parse(raw);
            generated = doc.RootElement
                .GetProperty("words")
                .EnumerateArray()
                .Select(ParseWord)
                .Where(w => w != null && IsValidWord(w.Word, existingWords))
                .ToList()!;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[Wordle] AI kelime parse hatası. Raw: {Raw}", raw);
            return 0;
        }

        // 2. DB'ye ekle — ON CONFLICT DO NOTHING mantığı ile upsert
        var added = 0;
        foreach (var gen in generated)
        {
            var alreadyExists = await _db.WordPool
                .AnyAsync(w => w.Word == gen.Word && w.Language == language);

            if (alreadyExists) continue;

            _db.WordPool.Add(new WordPool
            {
                Word       = gen.Word,
                Language   = language,
                Hint       = gen.Hint,
                Difficulty = gen.Difficulty,
                Source     = "ai_generated",
                CreatedAt  = DateTime.UtcNow,
            });
            added++;
        }

        if (added > 0) await _db.SaveChangesAsync();

        _logger.LogInformation("[Wordle] AI dolumu tamamlandı: {Count} yeni kelime eklendi.", added);
        return added;
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private static bool IsValidWord(string? word, ICollection<string> existing)
    {
        if (string.IsNullOrWhiteSpace(word)) return false;
        var upper = word.ToUpperInvariant().Trim();
        return upper.Length == 5 && !existing.Contains(upper);
    }

    private static string BuildPrompt(string language, int count, IList<string> existing)
    {
        var langLabel = language == "tr" ? "Turkish" : "English";
        var forbidden = existing.Count > 0
            ? "⛔ STRICTLY FORBIDDEN — These words already exist in the database. Do NOT generate these or similar words:\n" +
              string.Join(", ", existing.TakeLast(50))
            : string.Empty;

        return $$"""
You are a word generator for a Wordle-style game in {{langLabel}}.
Generate EXACTLY {{count}} common {{langLabel}} words that are EXACTLY 5 characters long.

Rules:
- Words must be exactly 5 characters (count each letter carefully — Ç,Ğ,İ,Ö,Ş,Ü each count as 1)
- Use UPPERCASE letters (proper Turkish uppercase: İ not I, etc.)
- Choose well-known, common words that people encounter in daily life
- Mix difficulty: some easy (everyday words), some medium, some harder
- Each word must be distinct and not a proper noun
- Include a short Turkish hint (1 brief phrase) for each word

{{(forbidden.Length > 0 ? forbidden + "\n\n" : "")}}Return ONLY valid JSON, no other text:
{
  "words": [
    {
      "word": "KELIME",
      "hint": "kısa ipucu Türkçe",
      "difficulty": 2
    }
  ]
}
""";
    }

    private static GeneratedWord? ParseWord(JsonElement el)
    {
        string Get(string key) =>
            el.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        int GetInt(string key, int def = 2)
        {
            if (!el.TryGetProperty(key, out var v)) return def;
            return v.TryGetInt32(out var i) ? i : def;
        }

        var word = Get("word").ToUpperInvariant().Trim();
        if (word.Length != 5) return null;

        return new GeneratedWord
        {
            Word       = word,
            Hint       = Get("hint"),
            Difficulty = Math.Clamp(GetInt("difficulty"), 1, 3),
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
                new { role = "system", content = "Sen bir Wordle kelime üreticisisin. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = prompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 1200,
            temperature     = 0.8,
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

    private sealed record GeneratedWord
    {
        public string Word       { get; init; } = string.Empty;
        public string? Hint      { get; init; }
        public int     Difficulty{ get; init; } = 2;
    }
}
