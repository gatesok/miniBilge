using System.Text.Json;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Writing;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Application.Services;

/// <summary>
/// GPT-4o-mini kullanarak yazma promptu üretir ve kullanıcı metinlerini değerlendirir.
/// HTTP çağrıları Program.cs'te yapılandırılan "openai" adlı HttpClient üzerinden gider.
/// </summary>
public class WritingService : IWritingService
{
    private readonly IOpenAiCompletionClient _openAi;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly ILogger<WritingService> _logger;

    // Skor eşiklerine göre ödül tablosu
    private const int CoinsHigh = 20; private const int StarsHigh = 2;  // ≥ 80
    private const int CoinsMid  = 10; private const int StarsMid  = 1;  // ≥ 50
    private const int CoinsLow  = 5;  private const int StarsLow  = 0;  // < 50

    public WritingService(
        IOpenAiCompletionClient openAi,
        IChildProfileRepository childProfileRepository,
        ILogger<WritingService> logger)
    {
        _openAi = openAi;
        _childProfileRepository = childProfileRepository;
        _logger = logger;
    }

    // ─── GeneratePromptsAsync ────────────────────────────────────────────────

    public async Task<List<WritingPromptDto>> GeneratePromptsAsync(GeneratePromptsRequest request)
    {
        var system = "You are a creative English teacher designing writing practice for children aged 6-12.";
        var user = $"Generate exactly 3 short writing practice prompts for CEFR level {request.Level}. " +
                   "Each prompt must be 1 sentence, age-appropriate, and vary in theme — " +
                   "mix imaginative, everyday life, school, nature, friendship, family, food, travel, " +
                   "or other relatable topics for children. Do not repeat the same theme. " +
                   "Return a JSON object with key \"prompts\" containing an array. " +
                   "Each item must have: \"promptText\" (string) and \"context\" (string or null).";

        var raw = await _openAi.CompleteJsonAsync(
            "writing_prompts_generate", system, user, 700, 0.7);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            return doc.RootElement
                .GetProperty("prompts")
                .EnumerateArray()
                .Select(p => new WritingPromptDto
                {
                    Id = Guid.NewGuid(),
                    PromptText = p.GetProperty("promptText").GetString() ?? string.Empty,
                    Context = p.TryGetProperty("context", out var ctx) && ctx.ValueKind != JsonValueKind.Null
                        ? ctx.GetString()
                        : null
                })
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GPT prompt parse hatası. Raw: {Raw}", raw);
            // Fallback: seviyeye göre statik promptlar
            return FallbackPrompts(request.Level);
        }
    }

    // ─── EvaluateWritingAsync ────────────────────────────────────────────────

    public async Task<WritingEvaluationResultDto> EvaluateWritingAsync(EvaluateWritingRequest request)
    {
        var system =
            $"You are an encouraging English teacher for children (age 6-12). " +
            $"Evaluate CEFR {request.Level} level writing. Be supportive, constructive, never harsh. " +
            $"Return ONLY valid JSON with exactly these keys: " +
            $"\"score\" (integer 0-100), " +
            $"\"feedback\" (string in English, max 2 sentences, always encouraging), " +
            $"\"feedbackTr\" (Turkish translation of feedback), " +
            $"\"corrections\" (array max 3, each with: \"original\", \"suggestion\", " +
            $"\"explanation\" (English, 1 sentence), \"explanationTr\" (Turkish translation of explanation)). " +
            $"Ignore minor punctuation for young learners.";

        var user = $"Prompt: \"{request.PromptText}\"\nStudent text: \"{request.Text}\"";

        var raw = await _openAi.CompleteJsonAsync(
            "writing_evaluate",
            system,
            user,
            700,
            0.7,
            request.ChildProfileId);

        WritingEvaluationResultDto result;

        try
        {
            using var doc = JsonDocument.Parse(raw);
            var root = doc.RootElement;

            var score      = root.GetProperty("score").GetInt32();
            var feedback   = root.TryGetProperty("feedback",   out var fb)   ? fb.GetString()   ?? "" : "";
            var feedbackTr = root.TryGetProperty("feedbackTr", out var fbTr) ? fbTr.GetString() ?? "" : "";
            var corrections = new List<WritingCorrectionDto>();

            if (root.TryGetProperty("corrections", out var corrs))
            {
                foreach (var c in corrs.EnumerateArray())
                {
                    corrections.Add(new WritingCorrectionDto
                    {
                        Original      = c.TryGetProperty("original",      out var o)  ? o.GetString()  ?? "" : "",
                        Suggestion    = c.TryGetProperty("suggestion",    out var s)  ? s.GetString()  ?? "" : "",
                        Explanation   = c.TryGetProperty("explanation",   out var e)  ? e.GetString()  ?? "" : "",
                        ExplanationTr = c.TryGetProperty("explanationTr", out var et) ? et.GetString() ?? "" : "",
                    });
                }
            }

            result = new WritingEvaluationResultDto
            {
                Score       = score,
                Corrections = corrections,
                Feedback    = feedback,
                FeedbackTr  = feedbackTr,
            };
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "GPT değerlendirme parse hatası. Raw: {Raw}", raw);
            result = new WritingEvaluationResultDto
            {
                Score      = 50,
                Feedback   = "Great effort! Keep writing and you'll improve every day.",
                FeedbackTr = "Harika bir deneme yaptın! Yazmaya devam et.",
            };
        }

        // Coin / yıldız ödülü (sadece çocuk profili varsa)
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

    private static List<WritingPromptDto> FallbackPrompts(string level) =>
    [
        new() { Id = Guid.NewGuid(), PromptText = "Write 2 sentences about your favourite animal.", Context = null },
        new() { Id = Guid.NewGuid(), PromptText = "Describe what you did yesterday.", Context = null },
        new() { Id = Guid.NewGuid(), PromptText = "What is your favourite food and why?", Context = null },
    ];
}
