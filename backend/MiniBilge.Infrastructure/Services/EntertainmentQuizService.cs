using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Eğlence quiz sorularını önce DB'den, yeterli yoksa GPT-4o-mini'den üretir.
/// </summary>
public class EntertainmentQuizService : IEntertainmentQuizService
{
    private readonly ApplicationDbContext              _db;
    private readonly IOpenAiCompletionClient           _openAi;
    private readonly ILogger<EntertainmentQuizService> _logger;

    public EntertainmentQuizService(
        ApplicationDbContext               db,
        IOpenAiCompletionClient            openAi,
        ILogger<EntertainmentQuizService>  logger)
    {
        _db     = db;
        _openAi = openAi;
        _logger = logger;
    }

    // ── Topic Listesi ─────────────────────────────────────────────────────────

    public IReadOnlyList<EntertainmentTopicDto> GetTopics()
        => EntertainmentTopics.All
            .Select(kv => new EntertainmentTopicDto
            {
                Key   = kv.Key,
                Label = kv.Value.Label,
                Emoji = kv.Value.Emoji,
            })
            .ToList();

    // ── Soru Üretimi (DB-first, GPT fallback) ────────────────────────────────

    public async Task<List<EntertainmentQuestionDto>> GenerateAsync(
        GenerateEntertainmentRequest req)
    {
        if (!EntertainmentTopics.All.TryGetValue(req.TopicKey, out var config))
            throw new InvalidOperationException($"Bilinmeyen topic: {req.TopicKey}");

        var difficulty = DifficultyInt(req.Difficulty);

        // ── 1. DB'den soru çek ───────────────────────────────────────────────
        var dbQuery = _db.EntertainmentQuizQuestions
            .Where(q => q.CategoryKey == req.TopicKey
                     && q.Difficulty  == difficulty
                     && q.Language    == "tr"
                     && q.IsActive);

        if (req.ExcludeIds.Count > 0)
            dbQuery = dbQuery.Where(q => !req.ExcludeIds.Contains(q.Id));

        var dbCount = await dbQuery.CountAsync();

        if (dbCount >= req.Count)
        {
            // Yeterli DB sorusu var — rastgele seç
            var dbQuestions = await dbQuery
                .OrderBy(_ => EF.Functions.Random())
                .Take(req.Count)
                .ToListAsync();

            return dbQuestions.Select(q => new EntertainmentQuestionDto
            {
                Id            = q.Id,
                QuestionText  = q.QuestionText,
                OptionA       = q.OptionA,
                OptionB       = q.OptionB,
                OptionC       = q.OptionC,
                OptionD       = q.OptionD,
                CorrectAnswer = q.CorrectAnswer,
                Explanation   = q.Explanation,
            }).ToList();
        }

        _logger.LogInformation("[Entertainment] DB'de {Count}/{Needed} soru, GPT fallback. Topic={T} Diff={D}",
            dbCount, req.Count, req.TopicKey, req.Difficulty);

        // ── 2. GPT fallback ───────────────────────────────────────────────────
        var subCats = PickSubCategories(config.SubCategories, req.Count);
        var prompt  = BuildPrompt(req, config, subCats);
        var raw = await _openAi.CompleteJsonAsync(
            "entertainment_quiz_generate",
            "Sen eğlenceli Türkçe quiz soruları üretiyorsun. Yalnızca geçerli JSON döndür.",
            prompt,
            maxTokens: 1500,
            temperature: 0.9);

        try
        {
            using var doc = JsonDocument.Parse(raw);
            return doc.RootElement
                .GetProperty("questions")
                .EnumerateArray()
                .Select(e => { var q = ParseQuestion(e); q.Id = 0; return q; })
                .ToList();
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[Entertainment] GPT parse hatası. Raw: {Raw}", raw);
            return [];
        }
    }

    private static int DifficultyInt(string difficulty) => difficulty switch
    {
        "Kolay" => 1,
        "Zor"   => 3,
        _       => 2,  // "Orta" default
    };

    // ── Helpers ──────────────────────────────────────────────────────────────

    private static string BuildPrompt(
        GenerateEntertainmentRequest req,
        TopicConfig config,
        IReadOnlyList<string> subCategories)
    {
        // Zorluk seviyesi — çok spesifik kurallarla tanımlanmış
        string difficultyTr, difficultyRules;
        switch (req.Difficulty)
        {
            case "Kolay":
                difficultyTr = "KOLAY";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions must be SO EASY that any adult can answer without thinking hard.\n" +
                    "- Only ask about VERY FAMOUS people, records, and events everyone knows.\n" +
                    "  Good example: \"Hangi renk kırmızı kart rengidir?\", \"Fenerbahçe'nin renkleri nelerdir?\"\n" +
                    "- The correct answer must be OBVIOUS to almost anyone.\n" +
                    "- Wrong options should be clearly different from the correct answer.\n" +
                    "- Do NOT ask about specific statistics, rare dates, or obscure details.\n" +
                    "- Do NOT make trick questions — keep it fun and immediately answerable.";
                break;
            case "Zor":
                difficultyTr = "ZOR";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions must be HARD and require expert-level knowledge.\n" +
                    "- Ask about specific statistics, rare records, exact dates, or lesser-known facts.\n" +
                    "- Even knowledgeable people should find these challenging.\n" +
                    "- Wrong options should be plausible and confusing.\n" +
                    "- Ask about details that only true enthusiasts would know.";
                break;
            default:
                difficultyTr = "ORTA";
                difficultyRules =
                    "DIFFICULTY RULES — STRICTLY FOLLOW:\n" +
                    "- Questions should require SOME knowledge but not expert-level.\n" +
                    "- Ask about well-known facts that interested people would know.\n" +
                    "- Wrong options should be reasonable but distinguishable.\n" +
                    "- Balance between obvious and obscure.";
                break;
        }

        // Yasak sorular listesi (max 15 — daha uzun liste prompt'u şişirip yavaşlatır)
        var forbidden = req.AskedQuestions.Count > 0
            ? "FORBIDDEN (do NOT repeat similar questions):\n" +
              string.Join("\n", req.AskedQuestions.TakeLast(100).Select(q => $"  - {q}"))
            : string.Empty;

        var date = req.DateSeed ?? DateTime.UtcNow.ToString("d MMMM yyyy");

        var languageRule = req.TopicKey.Equals("ingilizce", StringComparison.OrdinalIgnoreCase)
            ? "You are an English teacher. Generate ALL questions and answer options in English. Explanations may be in Turkish."
            : "You are a Turkish trivia quiz generator. Generate ALL questions and answers in Turkish.";
        var focus = string.IsNullOrWhiteSpace(req.FocusTopic) ? "mixed topics" : req.FocusTopic;

        return $$"""
{{languageRule}}

IMPORTANT: You MUST generate EXACTLY {{req.Count}} questions — no more, no less.

Topic: {{config.Label}} ({{config.Emoji}})
Topic hint: {{config.SystemHint}}
Selected focus: {{focus}}
Sub-categories for inspiration (try to cover different ones): {{string.Join(", ", subCategories)}}
DIFFICULTY LEVEL: {{difficultyTr}}
Date context: {{date}}

{{difficultyRules}}

{{(forbidden.Length > 0 ? forbidden + "\n\n" : "")}}Additional rules:
- Follow the language instruction at the top strictly
- Use varied question formats: "Hangisi doğrudur?", "Kaç yılında...?", "Kim...?", "Aşağıdakilerden hangisi...?", "Ne zaman...?"
- Make questions entertaining and educational
- Only one correct answer per question
- Add a short Turkish explanation for each correct answer
- GENERATE EXACTLY {{req.Count}} QUESTIONS IN THE JSON ARRAY

Return ONLY valid JSON, no other text:
{
  "questions": [
    {
      "questionText": "soru metni",
      "optionA": "A şıkkı",
      "optionB": "B şıkkı",
      "optionC": "C şıkkı",
      "optionD": "D şıkkı",
      "correctAnswer": "A",
      "explanation": "kısa açıklama"
    }
  ]
}
""";
    }

    private static IReadOnlyList<string> PickSubCategories(
        IReadOnlyList<string> all, int count)
    {
        // Karıştır, ilk N tanesini al
        var rng      = new Random();
        var shuffled = all.OrderBy(_ => rng.Next()).ToList();
        return shuffled.Take(Math.Min(count, shuffled.Count)).ToList();
    }

    private static EntertainmentQuestionDto ParseQuestion(JsonElement q)
    {
        string Get(string key) =>
            q.TryGetProperty(key, out var v) ? v.GetString() ?? "" : "";

        return new EntertainmentQuestionDto
        {
            QuestionText  = Get("questionText"),
            OptionA       = Get("optionA"),
            OptionB       = Get("optionB"),
            OptionC       = Get("optionC"),
            OptionD       = Get("optionD"),
            CorrectAnswer = Get("correctAnswer").ToUpper(),
            Explanation   = Get("explanation"),
        };
    }

}
