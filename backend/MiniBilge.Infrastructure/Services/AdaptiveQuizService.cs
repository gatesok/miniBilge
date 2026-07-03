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
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces;

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
    private readonly IChildProfileRepository      _childProfileRepo;
    private readonly ICardDropService             _cardDropService;
    private readonly IBadgeService                _badgeService;
    private readonly IProgressRepository          _progressRepo;
    private readonly ILogger<AdaptiveQuizService> _logger;

    public AdaptiveQuizService(
        ApplicationDbContext         db,
        IHttpClientFactory           http,
        IMemoryCache                 cache,
        IChildProfileRepository      childProfileRepo,
        ICardDropService             cardDropService,
        IBadgeService                badgeService,
        IProgressRepository          progressRepo,
        ILogger<AdaptiveQuizService> logger)
    {
        _db               = db;
        _http             = http;
        _cache            = cache;
        _childProfileRepo = childProfileRepo;
        _cardDropService  = cardDropService;
        _badgeService     = badgeService;
        _progressRepo     = progressRepo;
        _logger           = logger;
    }

    // ── Zayıf Konu Analizi ───────────────────────────────────────────────────

    public async Task<List<WeakTopicDto>> GetWeakTopicsAsync(Guid childId)
    {
        var attempts    = await _progressRepo.GetAnswerAttemptsWithTopicAsync(childId);
        var matchAnswers = await _progressRepo.GetMatchAnswersWithTopicAsync(childId);

        var soloItems = attempts
            .Where(a => a.Question?.Level?.Topic?.Subject != null)
            .Select(a => (Topic: a.Question.Level.Topic, IsCorrect: a.IsCorrect));

        var matchItems = matchAnswers
            .Where(a => a.Question?.Level?.Topic?.Subject != null)
            .Select(a => (Topic: a.Question.Level.Topic, IsCorrect: a.IsCorrect));

        return soloItems.Concat(matchItems)
            .GroupBy(x => x.Topic)
            .Select(g =>
            {
                var topic   = g.Key;
                var subject = topic.Subject?.Name ?? "";
                var total   = g.Count();
                var correct = g.Count(x => x.IsCorrect);
                var rate    = total > 0 ? (double)correct / total : 0.0;
                return new { Topic = topic, SubjectName = subject, Total = total, Rate = rate };
            })
            // Sadece İngilizce, en az 3 deneme, %70 altı
            .Where(x =>
                x.Total >= 3 &&
                x.Rate  <  0.70 &&
                (x.SubjectName.Contains("İngilizce", StringComparison.OrdinalIgnoreCase) ||
                 x.SubjectName.Contains("nglish",    StringComparison.OrdinalIgnoreCase)))
            .OrderBy(x => x.Rate)
            .Take(5)
            .Select(x => new WeakTopicDto
            {
                SubjectName         = x.SubjectName,
                TopicName           = x.Topic.Name,
                AvgSuccessPercent   = Math.Round(x.Rate * 100, 1),
                AttemptCount        = x.Total,
                SuggestedDifficulty = x.Rate < 0.40 ? 1 : x.Rate < 0.60 ? 2 : 3,
                EnglishLevel        = x.Topic.EnglishLevel.HasValue
                    ? x.Topic.EnglishLevel.Value.ToString() : null,
                GradeLevel          = 0,
            })
            .ToList();
    }

    // ── Soru Üretimi ─────────────────────────────────────────────────────────

    public async Task<List<AdaptiveQuestionDto>> GenerateQuestionsAsync(
        Guid childId, GenerateAdaptiveQuestionsRequest req)
    {
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
    // ── Ödül ─────────────────────────────────────────────────────────────────

    public async Task<AdaptiveQuizRewardDto> AwardAsync(
        Guid childId, AwardAdaptiveQuizRequest req)
    {
        var reward = new AdaptiveQuizRewardDto();
        double pct = req.TotalCount > 0
            ? (double)req.CorrectCount / req.TotalCount
            : 0;

        // Yıldız ve coin hesapla
        (reward.StarsEarned, reward.CoinsEarned) = pct switch
        {
            >= 1.0 => (3, 20),
            >= 0.7 => (2, 10),
            >= 0.4 => (1,  5),
            _      => (0,  2),
        };

        var child = await _childProfileRepo.GetByIdAsync(childId);
        if (child == null) return reward;

        child.TotalCoins += reward.CoinsEarned;
        child.TotalStars += reward.StarsEarned;
        await _db.SaveChangesAsync();

        // Kart — tam puan (5/5) veya %80+ ise kart düşer
        if (pct >= 0.8)
        {
            try
            {
                var drop = await _cardDropService.TryDropAsync(
                    childId, "quiz_complete", isGradeEligible: true);
                if (drop != null)
                {
                    reward.CardDropped    = true;
                    reward.CardName       = drop.CardName;
                    reward.CardRarity     = drop.Rarity;
                    reward.CardImageAsset = drop.ImageAsset;
                }
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "[AdaptiveQuiz] Kart drop hatası");
            }
        }

        // Rozet kontrol
        if (pct > 0)
        {
            try
            {
                var ctx = new MiniBilge.Application.Interfaces.Services.BadgeTriggerContext
                {
                    SuccessPercentage = pct * 100,
                };
                var badges = await _badgeService.CheckAndAwardAsync(
                    childId, BadgeTrigger.QuizCompleted, ctx);
                reward.BadgeCount = badges.Count;
            }
            catch (Exception ex)
            {
                _logger.LogWarning(ex, "[AdaptiveQuiz] Rozet hatası");
            }
        }

        return reward;
    }
    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string BuildPrompt(GenerateAdaptiveQuestionsRequest req)
    {
        // CEFR seviyesini topicName'den çıkar ("B2 English" → "B2")
        var cefrMatch = System.Text.RegularExpressions.Regex.Match(
            req.TopicName, @"\b(A1|A2|B1|B2|C1|C2)\b", 
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        var cefrLevel = cefrMatch.Success ? cefrMatch.Value.ToUpper() : null;

        string subjectHint;
        if (cefrLevel != null)
        {
            subjectHint = $"Generate questions ONLY in English for CEFR level {cefrLevel}. " +
                          $"Test grammar, vocabulary, and reading comprehension appropriate for {cefrLevel}. " +
                          "Do NOT use Turkish in questions or options.";
        }
        else if (req.SubjectName.Contains("atematik", StringComparison.OrdinalIgnoreCase) ||
                 req.SubjectName.Contains("ath",      StringComparison.OrdinalIgnoreCase))
        {
            subjectHint = $"Sorular Türkçe olsun ve {req.GradeLevel}. sınıf matematik müfredatına uygun olsun. " +
                          "Dört işlem, kesirler, geometri gibi konulardan sorular sor.";
        }
        else
        {
            subjectHint = "Soruları Türkçe yaz ve konu ile doğrudan ilgili tut.";
        }

        return $$"""
Sen {{(cefrLevel != null ? "an English language teacher" : $"{req.GradeLevel}. sınıf öğrencileri için bir eğitim asistanısın")}}.
{{subjectHint}}

Konu: {{req.TopicName}}
Zorluk seviyesi: {{req.Difficulty}}/5 (1=kolay, 5=çok zor)
Soru sayısı: {{req.Count}}

Kurallar:
- Her soru 4 şıklı çoktan seçmeli olsun (A, B, C, D)
- Doğru cevap yalnızca bir tane olsun
- Sorular birbiriyle aynı olmasın, farklı konuları test etsin
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
