using System.Net.Http;
using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Çocuğun performans geçmişine göre zayıf konuları tespit eder ve
/// GPT-4o-mini ile kişiselleştirilmiş sorular üretir.
/// </summary>
public class AdaptiveQuizService : IAdaptiveQuizService
{
    private readonly ApplicationDbContext         _db;
    private readonly IHttpClientFactory           _http;
    private readonly IMemoryCache                 _cache;
    private readonly ILogger<AdaptiveQuizService> _logger;

    public AdaptiveQuizService(
        ApplicationDbContext         db,
        IHttpClientFactory           http,
        IMemoryCache                 cache,
        ILogger<AdaptiveQuizService> logger)
    {
        _db     = db;
        _http   = http;
        _cache  = cache;
        _logger = logger;
    }

    // ── Zayıf Konu Analizi ───────────────────────────────────────────────────

    public async Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId)
    {
        var since = DateTime.UtcNow.AddDays(-30);

        var results = await _db.LevelResults
            .Include(r => r.Level)
                .ThenInclude(l => l.Topic)
                    .ThenInclude(t => t.Subject)
            .Where(r => r.ChildId == childId
                     && !r.IsDeleted
                     && r.CompletedAt >= since)
            .ToListAsync();

        return results
            .GroupBy(r => r.Level.Topic.Name)
            .Select(g => new
            {
                TopicName     = g.Key,
                SubjectName   = g.First().Level.Topic.Subject?.Name ?? "",
                AvgSuccess    = g.Average(r => (double)r.SuccessPercentage),
                AttemptCount  = g.Count(),
                AvgDifficulty = (int)Math.Round(g.Average(r => r.Level.Difficulty)),
            })
            .Where(x => x.AvgSuccess < 65 && x.AttemptCount >= 2)
            .OrderBy(x => x.AvgSuccess)
            .Take(3)
            .Select(x => new WeakTopicDto
            {
                SubjectName         = x.SubjectName,
                TopicName           = x.TopicName,
                AvgSuccessPercent   = Math.Round(x.AvgSuccess, 1),
                AttemptCount        = x.AttemptCount,
                SuggestedDifficulty = Math.Max(1, Math.Min(3, x.AvgDifficulty)),
            })
            .ToList();
    }

    // ── Soru Üretimi ─────────────────────────────────────────────────────────

    public async Task<List<AdaptiveQuestionDto>> GenerateQuestionsAsync(
        Guid childId, GenerateAdaptiveQuestionsRequest req)
    {
        var cacheKey = $"ai-quiz:{childId}:{req.TopicName}:{req.Difficulty}";
        if (_cache.TryGetValue(cacheKey, out List<AdaptiveQuestionDto>? cached) && cached != null)
            return cached;

        var prompt = BuildPrompt(req);
        var raw    = await CallGptAsync(prompt);

        List<AdaptiveQuestionDto> questions;
        try
        {
            using var doc = JsonDocument.Parse(raw);
            questions = doc.RootElement
                .GetProperty("questions")
                .EnumerateArray()
                .Select(q => ParseQuestion(q, req))
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[AdaptiveQuiz] GPT parse hatası. Raw: {Raw}", raw);
            return [];
        }

        // DB'e kaydet (cevaplanmamış olarak)
        var entities = questions.Select(q => new AiGeneratedQuestion
        {
            Id           = q.Id,
            ChildId      = childId,
            SubjectName  = req.SubjectName,
            TopicName    = req.TopicName,
            QuestionText = q.QuestionText,
            OptionsJson  = JsonSerializer.Serialize(new[] { q.OptionA, q.OptionB, q.OptionC, q.OptionD }),
            CorrectAnswer= q.CorrectAnswer,
            Explanation  = q.Explanation,
            Difficulty   = req.Difficulty,
            CreatedAt    = DateTime.UtcNow,
        }).ToList();

        _db.AiGeneratedQuestions.AddRange(entities);
        await _db.SaveChangesAsync();

        _cache.Set(cacheKey, questions, TimeSpan.FromHours(24));
        return questions;
    }

    // ── Cevap Kaydetme ───────────────────────────────────────────────────────

    public async Task SubmitAnswerAsync(Guid childId, SubmitAdaptiveAnswerRequest req)
    {
        var q = await _db.AiGeneratedQuestions
            .FirstOrDefaultAsync(x => x.Id == req.QuestionId && x.ChildId == childId);
        if (q == null) return;

        q.AnsweredAt = DateTime.UtcNow;
        q.IsCorrect  = string.Equals(q.CorrectAnswer, req.GivenAnswer,
                           StringComparison.OrdinalIgnoreCase);
        q.UpdatedAt  = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string BuildPrompt(GenerateAdaptiveQuestionsRequest req)
    {
        var subjectHint = req.SubjectName.ToLower() switch
        {
            var s when s.Contains("matematik") =>
                "Sorular matematikle ilgili olsun. Rakamlar, işlem adımları ve sayısal ifadeler kullan.",
            var s when s.Contains("ngilizce") || s.Contains("english") =>
                "Questions should be in English and test English grammar/vocabulary. Keep language age-appropriate.",
            _ => "Soruları Türkçe yaz ve konu ile doğrudan ilgili tut."
        };

        return $$"""
Sen {{req.GradeLevel}}. sınıf öğrencileri için çoktan seçmeli soru üreten bir eğitim asistanısın.
{{subjectHint}}

Konu: {{req.TopicName}}
Zorluk seviyesi: {{req.Difficulty}}/5 (1=kolay, 5=çok zor)
Soru sayısı: {{req.Count}}

Kurallar:
- Her soru 4 şıklı çoktan seçmeli olsun (A, B, C, D)
- Doğru cevap yalnızca bir tane olsun
- Sorular birbiriyle aynı olmasın, farklı alt konuları test etsin
- Yaşa uygun, sade ve anlaşılır dil kullan
- Her soruya kısa bir açıklama (explanation) ekle

JSON formatında döndür — sadece JSON, başka metin ekleme:
{
  "questions": [
    {
      "questionText": "soru metni",
      "optionA": "A seçeneği",
      "optionB": "B seçeneği",
      "optionC": "C seçeneği",
      "optionD": "D seçeneği",
      "correctAnswer": "A",
      "explanation": "kısa açıklama"
    }
  ]
}
""";
    }

    private static AdaptiveQuestionDto ParseQuestion(
        JsonElement q, GenerateAdaptiveQuestionsRequest req)
    {
        string Get(string key) =>
            q.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        return new AdaptiveQuestionDto
        {
            Id            = Guid.NewGuid(),
            QuestionText  = Get("questionText"),
            OptionA       = Get("optionA"),
            OptionB       = Get("optionB"),
            OptionC       = Get("optionC"),
            OptionD       = Get("optionD"),
            CorrectAnswer = Get("correctAnswer").ToUpper(),
            Explanation   = Get("explanation"),
            SubjectName   = req.SubjectName,
            TopicName     = req.TopicName,
            Difficulty    = req.Difficulty,
        };
    }

    private async Task<string> CallGptAsync(string userPrompt)
    {
        var client = _http.CreateClient("openai");

        var body = new
        {
            model           = "gpt-4o-mini",
            messages        = new[]
            {
                new { role = "system", content = "Sen bir eğitim asistanısın. Yalnızca geçerli JSON döndür." },
                new { role = "user",   content = userPrompt },
            },
            response_format = new { type = "json_object" },
            max_tokens      = 1200,
            temperature     = 0.7,
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
