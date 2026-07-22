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
    private readonly IOpenAiCompletionClient      _openAi;
    private readonly IMemoryCache                 _cache;
    private readonly IChildProfileRepository      _childProfileRepo;
    private readonly ICardDropService             _cardDropService;
    private readonly IBadgeService                _badgeService;
    private readonly IProgressRepository          _progressRepo;
    private readonly ILogger<AdaptiveQuizService> _logger;

    public AdaptiveQuizService(
        ApplicationDbContext         db,
        IOpenAiCompletionClient      openAi,
        IMemoryCache                 cache,
        IChildProfileRepository      childProfileRepo,
        ICardDropService             cardDropService,
        IBadgeService                badgeService,
        IProgressRepository          progressRepo,
        ILogger<AdaptiveQuizService> logger)
    {
        _db               = db;
        _openAi           = openAi;
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
        // Son 7 günde, konu bazında son 5 soruya bak → hepsi doğruysa mastered
        var recentAiQuestions = await _db.AiGeneratedQuestions
            .Where(q => q.ChildId == childId
                     && q.CreatedAt  >= DateTime.UtcNow.AddDays(-7)
                     && q.AnsweredAt != null)
            .ToListAsync();

        var masteredTopics = recentAiQuestions
            .GroupBy(q => q.TopicName)
            .Where(g =>
            {
                // Bu konunun en son 5 sorusunu al (oturumdan bağımsız)
                var last5 = g.OrderByDescending(q => q.CreatedAt).Take(5).ToList();
                return last5.Count == 5 && last5.All(q => q.IsCorrect == true);
            })
            .Select(g => g.Key)
            .ToList();

        var attempts    = await _progressRepo.GetAnswerAttemptsWithTopicAsync(childId);
        var matchAnswers = await _progressRepo.GetMatchAnswersWithTopicAsync(childId);

        // Son 90 gün — daha öncesini sorgulamak performansta anlamsız
        var since = DateTime.UtcNow.AddDays(-90);

        var soloItems = attempts
            .Where(a => a.Question?.Level?.Topic?.Subject != null
                     && a.AttemptedAt >= since)
            .Select(a => (Topic: a.Question.Level.Topic, IsCorrect: a.IsCorrect));

        var matchItems = matchAnswers
            .Where(a => a.Question?.Level?.Topic?.Subject != null
                     && a.AnsweredAt >= since)
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
            .Where(x =>
                x.Total >= 3 &&
                x.Rate  <  0.70 &&
                (x.SubjectName.Contains("İngilizce", StringComparison.OrdinalIgnoreCase) ||
                 x.SubjectName.Contains("nglish",    StringComparison.OrdinalIgnoreCase)))
            .OrderBy(x => masteredTopics.Contains(x.Topic.Name) ? 1 : 0) // Mastered olanlar alta
            .ThenBy(x => x.Rate)
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
                IsMastered          = masteredTopics.Contains(x.Topic.Name),
            })
            .ToList();
    }

    // ── Soru Üretimi ─────────────────────────────────────────────────────────

    public async Task<List<AdaptiveQuestionDto>> GenerateQuestionsAsync(
        Guid childId, GenerateAdaptiveQuestionsRequest req)
    {
        // Daha önce sorulan soruları çıkar — tekrar önlemek için
        var prevQuestions = await _db.AiGeneratedQuestions
            .Where(q => q.ChildId == childId && q.TopicName == req.TopicName)
            .OrderByDescending(q => q.CreatedAt)
            .Take(20)
            .Select(q => q.QuestionText)
            .ToListAsync();

        var prompt = BuildPrompt(req, prevQuestions);
        var raw = await _openAi.CompleteJsonAsync(
            "adaptive_quiz_generate",
            "Sen bir eğitim asistanısın. Yalnızca geçerli JSON döndür.",
            prompt,
            maxTokens: 1200,
            temperature: 0.7,
            childProfileId: childId);

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

        // Katmanlı ödül sistemi
        reward.StarsEarned = pct switch
        {
            >= 1.0  => 3,  // %100 mükemmel
            >= 0.90 => 3,  // %90+  harika
            >= 0.80 => 2,  // %80+  iyi
            >= 0.60 => 1,  // %60+  orta
            _       => 0,
        };

        // 5/5 yapılırsa konu mastered
        reward.TopicMastered = pct >= 1.0;

        var child = await _childProfileRepo.GetByIdAsync(childId);
        if (child == null) return reward;

        child.TotalStars += reward.StarsEarned;

        // ── Leaderboard skoru güncelle ────────────────────────────────────────
        // Eğitim quizi ProgressService üzerinden günceller; burada sadece
        // eğlence/ödül quiz'leri için ChildProgress.TotalScore güncellenmeli.
        const int pointsPerCorrect = 10;
        var scoreToAdd = req.CorrectCount * pointsPerCorrect;
        if (scoreToAdd > 0)
        {
            var progress = await _db.ChildProgresses
                .FirstOrDefaultAsync(p => p.ChildId == childId);
            if (progress == null)
            {
                progress = new MiniBilge.Domain.Entities.ChildProgress
                {
                    Id       = Guid.NewGuid(),
                    ChildId  = childId,
                    TotalScore = scoreToAdd,
                    TotalStars = reward.StarsEarned,
                };
                _db.ChildProgresses.Add(progress);
            }
            else
            {
                progress.TotalScore += scoreToAdd;
                progress.TotalStars += reward.StarsEarned;
                _db.ChildProgresses.Update(progress);
            }
        }

        await _db.SaveChangesAsync();

        // Kart: %80+ kart düşer, kaynak yüzdeye göre değişir
        if (pct >= 0.80)
        {
            var cardSource = pct >= 1.0  ? "ai_quiz_perfect"
                           : pct >= 0.90 ? "ai_quiz_high"
                           :               "quiz_complete";
            try
            {
                var drop = await _cardDropService.TryDropAsync(
                    childId, cardSource, isGradeEligible: true);
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

    private static string BuildPrompt(GenerateAdaptiveQuestionsRequest req,
        List<string>? prevQuestions = null)
    {
        // CEFR seviyesi: önce req.EnglishLevel, yoksa TopicName'den regex ile çıkar
        var cefrFromTopic = System.Text.RegularExpressions.Regex.Match(
            req.TopicName, @"\b(A1|A2|B1|B2|C1|C2)\b",
            System.Text.RegularExpressions.RegexOptions.IgnoreCase);

        var cefrLevel = !string.IsNullOrEmpty(req.EnglishLevel)
            ? req.EnglishLevel.ToUpper()
            : cefrFromTopic.Success
                ? cefrFromTopic.Value.ToUpper()
                : null;

        bool isEnglish = cefrLevel != null
            || req.SubjectName.Contains("ngilizce", StringComparison.OrdinalIgnoreCase)
            || req.SubjectName.Contains("nglish",   StringComparison.OrdinalIgnoreCase);

        string subjectHint;
        if (isEnglish)
        {
            var level = cefrLevel ?? "intermediate";
            subjectHint = $"You are an English language teacher. " +
                          $"Generate ALL questions and ALL answer options ONLY in English. " +
                          $"CEFR level: {level}. " +
                          $"Topic: {req.TopicName}. " +
                          $"Focus specifically on this topic. " +
                          $"Do NOT write anything in Turkish.";
        }
        else if (req.SubjectName.Contains("atematik", StringComparison.OrdinalIgnoreCase))
        {
            subjectHint = $"Sorular Türkçe olsun, {req.GradeLevel}. sınıf matematik müfredatına uygun olsun. " +
                          $"Konu: {req.TopicName}.";
        }
        else
        {
            subjectHint = $"Soruları Türkçe yaz. Konu: {req.TopicName}.";
        }

        return $$"""
{{subjectHint}}

Difficulty: {{req.Difficulty}}/5
Number of questions: {{req.Count}}

Rules:
- Each question must have exactly 4 answer choices (A, B, C, D)
- Only one correct answer per question
- Questions must be varied and test different aspects of the topic
- Add a short explanation for each correct answer
- IMPORTANT: Do NOT generate questions that are similar or identical to these previously asked questions:
{{(prevQuestions?.Count > 0 ? string.Join("\n", prevQuestions.Select(q => $"  - {q}")) : "  (none yet)")}}

Return ONLY valid JSON, no other text:
{
  "questions": [
    {
      "questionText": "question text here",
      "optionA": "option A",
      "optionB": "option B",
      "optionC": "option C",
      "optionD": "option D",
      "correctAnswer": "A",
      "explanation": "brief explanation"
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

}
