using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Pronunciation;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

/// <summary>
/// Hedef cümle ile speech_to_text çıktısını kelime kelime karşılaştırır.
/// Levenshtein distance ile yakın eşleşmeler tolere edilir.
/// Yanlış kelimelere GPT-4o-mini ile kısa Türkçe telaffuz ipucu üretilir.
/// </summary>
public class PronunciationService : IPronunciationService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IFlashcardRepository _flashcardRepository;
    private readonly ILogger<PronunciationService> _logger;

    // Levenshtein toleransı: kısa kelimeler (≤4 harf) için 1, uzun kelimeler için 2
    private const int ShortWordTolerance = 1;
    private const int LongWordTolerance  = 2;
    private const int ShortWordThreshold = 4;

    // GPT hint en fazla bu kadar yanlış kelime için üretilir (token tasarrufu)
    private const int MaxHintWords = 3;

    public PronunciationService(
        IHttpClientFactory httpClientFactory,
        IFlashcardRepository flashcardRepository,
        ILogger<PronunciationService> logger)
    {
        _httpClientFactory    = httpClientFactory;
        _flashcardRepository  = flashcardRepository;
        _logger               = logger;
    }

    // ─── GetSentencesAsync ────────────────────────────────────────────────────

    public async Task<List<string>> GetSentencesAsync(int level, int count = 10)
    {
        if (Enum.IsDefined(typeof(EnglishLevel), level))
        {
            var dbSentences = (await _flashcardRepository
                .GetExampleSentencesByLevelAsync((EnglishLevel)level, count))
                .ToList();

            if (dbSentences.Count > 0)
                return dbSentences;
        }

        return FallbackSentences(level);
    }

    private static List<string> FallbackSentences(int level) => level switch
    {
        1 => // A1
        [
            "Hello, my name is Alex.",
            "I have a cat and a dog.",
            "The apple is red.",
            "She is my teacher.",
            "We go to school every day.",
        ],
        2 => // A2
        [
            "I usually wake up at seven o'clock.",
            "My favourite colour is blue.",
            "She likes reading books in the evening.",
            "We are going to the park tomorrow.",
            "He has two brothers and one sister.",
        ],
        3 => // B1
        [
            "I have been learning English for three years.",
            "She decided to travel around Europe last summer.",
            "The weather was beautiful when we arrived.",
            "He said he would call me back later.",
            "They enjoyed watching the documentary about nature.",
        ],
        _ =>
        [
            "The quick brown fox jumps over the lazy dog.",
            "She studied hard for the exam.",
            "We celebrated his birthday last weekend.",
            "The children played in the garden all afternoon.",
            "He forgot to bring his umbrella.",
        ],
    };

    // ─── EvaluatePronunciationAsync ───────────────────────────────────────────

    public async Task<PronunciationResultDto> EvaluatePronunciationAsync(EvaluatePronunciationRequest request)
    {
        var targetWords = Tokenize(request.TargetSentence);
        var spokenWords = Tokenize(request.SpokenText);

        // Her hedef kelimeyi konuşulan kelimelerle karşılaştır
        var wordResults = targetWords
            .Select(t => new WordResultDto
            {
                Word      = t,
                IsCorrect = IsMatch(t, spokenWords),
            })
            .ToList();

        // Yanlış kelimelere GPT ipucu ekle (en fazla MaxHintWords adet)
        var wrongWords = wordResults
            .Where(w => !w.IsCorrect)
            .Take(MaxHintWords)
            .Select(w => w.Word)
            .ToList();

        if (wrongWords.Count > 0)
        {
            var hints = await GenerateHintsAsync(wrongWords, request.Level);
            foreach (var wr in wordResults.Where(w => !w.IsCorrect).Take(MaxHintWords))
            {
                if (hints.TryGetValue(wr.Word.ToLowerInvariant(), out var hint))
                    wr.Hint = hint;
            }
        }

        var correctCount = wordResults.Count(w => w.IsCorrect);
        var overallScore = targetWords.Count > 0
            ? (int)Math.Round(100.0 * correctCount / targetWords.Count)
            : 0;

        return new PronunciationResultDto
        {
            Words        = wordResults,
            OverallScore = overallScore,
        };
    }

    // ─── Tokenize ────────────────────────────────────────────────────────────

    /// <summary>Metni normalize ederek kelime listesine dönüştürür.</summary>
    private static List<string> Tokenize(string text)
    {
        if (string.IsNullOrWhiteSpace(text))
            return [];

        // Noktalama işaretlerini kaldır, küçük harfe çevir
        var clean = Regex.Replace(text.ToLowerInvariant(), @"[^\w\s]", "");
        return clean
            .Split(' ', StringSplitOptions.RemoveEmptyEntries)
            .ToList();
    }

    // ─── Eşleşme Kontrolü ────────────────────────────────────────────────────

    /// <summary>
    /// Hedef kelimeyi konuşulan kelimeler listesiyle karşılaştırır.
    /// Levenshtein toleransı ile yakın eşleşmeleri de doğru sayar.
    /// </summary>
    private static bool IsMatch(string targetWord, List<string> spokenWords)
    {
        var tolerance = targetWord.Length <= ShortWordThreshold
            ? ShortWordTolerance
            : LongWordTolerance;

        return spokenWords.Any(spoken =>
            Levenshtein(targetWord, spoken) <= tolerance);
    }

    // ─── Levenshtein Distance ─────────────────────────────────────────────────

    private static int Levenshtein(string a, string b)
    {
        if (a == b)         return 0;
        if (a.Length == 0)  return b.Length;
        if (b.Length == 0)  return a.Length;

        var prev = new int[b.Length + 1];
        var curr = new int[b.Length + 1];

        for (var j = 0; j <= b.Length; j++) prev[j] = j;

        for (var i = 1; i <= a.Length; i++)
        {
            curr[0] = i;
            for (var j = 1; j <= b.Length; j++)
            {
                var cost = a[i - 1] == b[j - 1] ? 0 : 1;
                curr[j] = Math.Min(
                    Math.Min(curr[j - 1] + 1, prev[j] + 1),
                    prev[j - 1] + cost);
            }
            Array.Copy(curr, prev, b.Length + 1);
        }

        return prev[b.Length];
    }

    // ─── GPT Hint Üretimi ─────────────────────────────────────────────────────

    /// <summary>
    /// Yanlış kelimelere İngilizce telaffuz ipucu üretir.
    /// Tek bir GPT çağrısı ile tüm kelimeler için ipucu alınır.
    /// </summary>
    private async Task<Dictionary<string, string>> GenerateHintsAsync(
        List<string> wrongWords, string level)
    {
        var wordList = string.Join(", ", wrongWords.Select(w => $"\"{w}\""));

        var system =
            "You are a helpful English pronunciation coach for children (age 6-12). " +
            "Provide very short, simple Turkish pronunciation tips for each word. " +
            "Return ONLY valid JSON with keys being the lowercase English words " +
            "and values being the Turkish tip (max 1 short sentence each).";

        var user =
            $"CEFR level: {level}. Give a Turkish pronunciation tip for each of these words: {wordList}. " +
            "Example format: {{\"beautiful\": \"'byuu-ti-ful' şeklinde okunur\"}}";

        try
        {
            var client = _httpClientFactory.CreateClient("openai");

            var body = new
            {
                model    = "gpt-4o-mini",
                messages = new[]
                {
                    new { role = "system", content = system },
                    new { role = "user",   content = user   },
                },
                response_format = new { type = "json_object" },
                max_tokens      = 200,
                temperature     = 0.3,
            };

            var json     = JsonSerializer.Serialize(body);
            var content  = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync("chat/completions", content);
            response.EnsureSuccessStatusCode();

            var responseJson = await response.Content.ReadAsStringAsync();
            using var doc    = JsonDocument.Parse(responseJson);
            var raw          = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString() ?? "{}";

            using var hintDoc = JsonDocument.Parse(raw);
            return hintDoc.RootElement
                .EnumerateObject()
                .ToDictionary(
                    p => p.Name.ToLowerInvariant(),
                    p => p.Value.GetString() ?? string.Empty);
        }
        catch (Exception ex)
        {
            _logger.LogWarning(ex, "GPT hint üretilemedi, ipuçsuz devam edilecek.");
            return new Dictionary<string, string>();
        }
    }
}
