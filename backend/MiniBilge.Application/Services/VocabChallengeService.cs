using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Writing;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

/// <summary>
/// Çocuğun öğrendiği flashcard kelimelerini kullanarak GPT-4o-mini ile
/// kişiselleştirilmiş yazma görevi üretir ve değerlendirir.
/// </summary>
public class VocabChallengeService : IVocabChallengeService
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly IFlashcardRepository _flashcardRepository;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly ILogger<VocabChallengeService> _logger;

    private const int CoinsHigh = 20; private const int StarsHigh = 2;
    private const int CoinsMid  = 10; private const int StarsMid  = 1;
    private const int CoinsLow  = 5;  private const int StarsLow  = 0;

    public VocabChallengeService(
        IHttpClientFactory httpClientFactory,
        IFlashcardRepository flashcardRepository,
        IChildProfileRepository childProfileRepository,
        ILogger<VocabChallengeService> logger)
    {
        _httpClientFactory = httpClientFactory;
        _flashcardRepository = flashcardRepository;
        _childProfileRepository = childProfileRepository;
        _logger = logger;
    }

    // ─── GenerateChallengeAsync ──────────────────────────────────────────────

    public async Task<VocabChallengeTaskDto> GenerateChallengeAsync(GenerateVocabChallengeRequest request)
    {
        var level = ParseLevel(request.Level);

        // Çocuğun o seviyede incelediği kartları getir
        var cards = (await _flashcardRepository.GetReviewedFlashcardsByLevelAsync(request.ChildId, level))
                    .ToList();

        // 3 kelime seç
        var rng = new Random();
        var targetWords = cards
            .OrderBy(_ => rng.Next())
            .Take(3)
            .Select(c => c.FrontText)
            .ToList();

        if (targetWords.Count == 0)
            targetWords = new List<string> { "happy", "explore", "beautiful" };

        var task = await GenerateTaskWithGptAsync(targetWords, request.Level);

        return new VocabChallengeTaskDto
        {
            Task        = task,
            TargetWords = targetWords,
        };
    }

    // ─── EvaluateChallengeAsync ──────────────────────────────────────────────

    public async Task<VocabChallengeResultDto> EvaluateChallengeAsync(EvaluateVocabChallengeRequest request)
    {
        var wordList = string.Join(", ", request.TargetWords.Select(w => $"\"{w}\""));

        var system =
            $"You are an encouraging English teacher for children (age 6-12). " +
            $"Evaluate CEFR {request.Level} level writing. Be supportive and constructive, never harsh. " +
            $"The student was asked to use these target words: {wordList}. " +
            $"Return ONLY valid JSON with exactly these keys: " +
            $"\"score\" (integer 0-100, boost +5 for each target word used correctly), " +
            $"\"targetWordUsage\" (object: each target word as key, boolean as value — true if used correctly), " +
            $"\"corrections\" (array max 3, each: \"original\", \"suggestion\", \"explanation\" in Turkish), " +
            $"\"feedback\" (string in Turkish, max 2 sentences, always encouraging, mention target words used).";

        var user = $"Task: \"{request.TaskText}\"\nStudent text: \"{request.Text}\"";

        var raw = await CallGptAsync(system, user);

        VocabChallengeResultDto result;

        try
        {
            using var doc = JsonDocument.Parse(raw);
            var root = doc.RootElement;

            var score    = root.GetProperty("score").GetInt32();
            var feedback = root.TryGetProperty("feedback", out var fb) ? fb.GetString() ?? "" : "";

            // Hedef kelime kullanımı
            var usage = new Dictionary<string, bool>();
            if (root.TryGetProperty("targetWordUsage", out var twu))
            {
                foreach (var word in request.TargetWords)
                {
                    if (twu.TryGetProperty(word, out var val))
                        usage[word] = val.GetBoolean();
                    else
                        usage[word] = false;
                }
            }

            // Düzeltmeler
            var corrections = new List<WritingCorrectionDto>();
            if (root.TryGetProperty("corrections", out var corrs))
            {
                foreach (var c in corrs.EnumerateArray())
                {
                    corrections.Add(new WritingCorrectionDto
                    {
                        Original    = c.TryGetProperty("original",    out var o) ? o.GetString() ?? "" : "",
                        Suggestion  = c.TryGetProperty("suggestion",  out var s) ? s.GetString() ?? "" : "",
                        Explanation = c.TryGetProperty("explanation", out var e) ? e.GetString() ?? "" : "",
                    });
                }
            }

            result = new VocabChallengeResultDto
            {
                Score           = Math.Clamp(score, 0, 100),
                TargetWordUsage = usage,
                Corrections     = corrections,
                Feedback        = feedback,
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "VocabChallenge değerlendirme parse hatası. Raw: {Raw}", raw);
            result = new VocabChallengeResultDto
            {
                Score    = 50,
                Feedback = "Harika bir deneme yaptın! Kelimeleri kullanmaya devam et.",
                TargetWordUsage = request.TargetWords.ToDictionary(w => w, _ => false),
            };
        }

        // Coin / yıldız ödülü
        if (request.ChildProfileId.HasValue)
        {
            var (coins, stars) = result.Score >= 80 ? (CoinsHigh, StarsHigh)
                               : result.Score >= 50 ? (CoinsMid,  StarsMid)
                               :                      (CoinsLow,  StarsLow);

            var child = await _childProfileRepository.GetByIdAsync(request.ChildProfileId.Value);
            if (child is not null)
            {
                child.TotalCoins += coins;
                child.TotalStars += stars;
                await _childProfileRepository.UpdateAsync(child);
            }

            result.CoinsEarned = coins;
            result.StarsEarned = stars;
        }

        return result;
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    private async Task<string> GenerateTaskWithGptAsync(List<string> targetWords, string level)
    {
        var wordList = string.Join(", ", targetWords.Select(w => $"\"{w}\""));
        var system   = "You are a creative English teacher designing writing tasks for children aged 6-12.";
        var user     = $"Generate a fun, short writing task (1-2 sentences) for a CEFR {level} student " +
                       $"that requires them to use these words: {wordList}. " +
                       $"Make it imaginative and age-appropriate. " +
                       $"Return ONLY valid JSON: {{\"task\": \"...\"}}";

        var raw = await CallGptAsync(system, user);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            return doc.RootElement.GetProperty("task").GetString() ?? FallbackTask(targetWords);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Görev üretme parse hatası. Raw: {Raw}", raw);
            return FallbackTask(targetWords);
        }
    }

    private static string FallbackTask(List<string> words)
    {
        var joined = string.Join(", ", words.Select(w => $"'{w}'"));
        return $"Write 3-4 sentences using the words: {joined}.";
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
            temperature = 0.7,
        };

        var json     = JsonSerializer.Serialize(body);
        var content  = new StringContent(json, Encoding.UTF8, "application/json");
        var response = await client.PostAsync("chat/completions", content);
        response.EnsureSuccessStatusCode();

        var responseJson = await response.Content.ReadAsStringAsync();

        using var doc = JsonDocument.Parse(responseJson);
        return doc.RootElement
                  .GetProperty("choices")[0]
                  .GetProperty("message")
                  .GetProperty("content")
                  .GetString() ?? "{}";
    }

    private static EnglishLevel ParseLevel(string level) => level.ToUpperInvariant() switch
    {
        "A1" => EnglishLevel.A1,
        "A2" => EnglishLevel.A2,
        "B1" => EnglishLevel.B1,
        "B2" => EnglishLevel.B2,
        "C1" => EnglishLevel.C1,
        "C2" => EnglishLevel.C2,
        _    => EnglishLevel.A1,
    };
}
