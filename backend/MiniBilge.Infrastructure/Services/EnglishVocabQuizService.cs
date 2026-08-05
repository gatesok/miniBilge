using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Common;
using MiniBilge.Application.DTOs.EnglishVocab;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// İngilizce kelime oyunu: kelimeler DB'den (english_vocab_word) rastgele seçilir; her doğru
/// kelime için 3 çeldirici öncelikle aynı anlam grubundan (SemanticGroup), yoksa aynı CEFR
/// seviyesi + aynı sözcük türünden dinamik üretilir.
/// Havuz yetersizse kaliteyi koruyarak kademeli gevşetme uygulanır (asla serbest rastgele değil).
/// </summary>
public class EnglishVocabQuizService : IEnglishVocabQuizService
{
    private static readonly string[] CefrOrder = { "A1", "A2", "B1", "B2", "C1", "C2" };
    private const int OptionsPerQuestion = 4; // 1 doğru + 3 çeldirici

    private readonly ApplicationDbContext             _db;
    private readonly ILogger<EnglishVocabQuizService> _logger;

    public EnglishVocabQuizService(
        ApplicationDbContext             db,
        ILogger<EnglishVocabQuizService> logger)
    {
        _db     = db;
        _logger = logger;
    }

    public async Task<List<VocabQuestionDto>> GenerateAsync(GenerateVocabQuizRequest req)
    {
        var level = NormalizeLevel(req.EnglishLevel);
        if (level == null)
            throw new InvalidOperationException($"Geçersiz CEFR seviyesi: {req.EnglishLevel}");

        var count = Math.Clamp(req.Count, 1, 20);

        // Doğru kelimeler: seçili seviye + aktif, hariç tutulanlar dışında, rastgele.
        // Çeldirici üretememe ihtimaline karşı bir miktar fazla çekip geçerli olanları alırız.
        var overFetch = Math.Min(count * 2, count + 10);
        var wordQuery = _db.EnglishVocabWords
            .Where(w => w.IsActive && w.EnglishLevel == level);
        if (req.ExcludeIds.Count > 0)
            wordQuery = wordQuery.Where(w => !req.ExcludeIds.Contains(w.Id));

        var words = await wordQuery
            .OrderBy(_ => EF.Functions.Random())
            .Take(overFetch)
            .ToListAsync();

        if (words.Count == 0)
        {
            _logger.LogWarning("[EnglishVocab] {Level} seviyesinde uygun kelime bulunamadı.", level);
            return [];
        }

        // Çeldirici havuzu: seçili seviye + komşu seviyeler (kademeli fallback için).
        var neighborLevels = NeighborLevels(level);
        var poolLevels = new HashSet<string>(neighborLevels) { level };

        var pool = await _db.EnglishVocabWords
            .Where(w => w.IsActive && poolLevels.Contains(w.EnglishLevel))
            .Select(w => new PoolItem
            {
                Id            = w.Id,
                Meaning       = w.TurkishMeaning,
                PartOfSpeech  = w.PartOfSpeech,
                Level         = w.EnglishLevel,
                SemanticGroup = w.SemanticGroup,
            })
            .ToListAsync();

        var result = new List<VocabQuestionDto>(count);
        foreach (var word in words)
        {
            if (result.Count >= count) break;

            var distractors = PickDistractors(word, level, pool);
            if (distractors.Count < OptionsPerQuestion - 1)
            {
                // Bu kelime için yeterli kaliteli çeldirici yok — atla.
                continue;
            }

            result.Add(BuildQuestion(word, distractors));
        }

        return result;
    }

    public async Task RecordCompletionAsync(Guid childId, AwardVocabQuizRequest request)
    {
        try
        {
            // Idempotency: aynı ödül anahtarıyla ikinci kez kaydetme.
            if (!string.IsNullOrWhiteSpace(request.RewardEventId))
            {
                var exists = await _db.EnglishVocabActivities.AnyAsync(a =>
                    a.ChildProfileId == childId && a.IdempotencyKey == request.RewardEventId);
                if (exists) return;
            }

            var duration = Math.Clamp(request.DurationSeconds ?? 0, 0, 3600);
            var now = DateTime.UtcNow;

            _db.EnglishVocabActivities.Add(new EnglishVocabActivity
            {
                Id             = Guid.NewGuid(),
                ChildProfileId = childId,
                EnglishLevel   = NormalizeLevel(request.EnglishLevel) ?? string.Empty,
                QuestionCount  = Math.Max(0, request.TotalCount),
                CorrectCount   = Math.Max(0, request.CorrectCount),
                DurationSeconds = duration,
                CompletedAt    = now,
                IdempotencyKey = string.IsNullOrWhiteSpace(request.RewardEventId)
                    ? null : request.RewardEventId,
                CreatedAt      = now,
            });
            await _db.SaveChangesAsync();

            await UpdateStreakAsync(childId);
        }
        catch (Exception ex)
        {
            // Aktivite/streak kaydı ödülü bloklamamalı; sessizce geç.
            _logger.LogWarning(ex, "[EnglishVocab] Aktivite/streak kaydı hatası");
        }
    }

    // ── Streak ───────────────────────────────────────────────────────────────

    private async Task UpdateStreakAsync(Guid childId)
    {
        var profile = await _db.Set<ChildProfile>().FirstOrDefaultAsync(c => c.Id == childId);
        if (profile == null) return;

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (profile.LastActivityDate == today) return;

        var newStreak = StreakCalculator.Next(profile.CurrentStreak, profile.LastActivityDate, today);
        profile.CurrentStreak = newStreak;
        if (newStreak > profile.LongestStreak) profile.LongestStreak = newStreak;
        profile.LastActivityDate = today;
        await _db.SaveChangesAsync();
    }

    // ── Çeldirici seçimi (kademeli, kaliteyi koruyarak) ───────────────────────

    private static List<string> PickDistractors(EnglishVocabWord word, string level, List<PoolItem> pool)
    {
        var correctMeaning = Normalize(word.TurkishMeaning);
        var used = new HashSet<string> { correctMeaning };
        var chosen = new List<string>();

        // Kalite sırasına göre aday katmanları:
        //  0) aynı seviye + aynı anlam grubu (en kandırıcı — aynı temadan tuzak; grup doluysa)
        //  1) aynı seviye + aynı sözcük türü
        //  2) aynı seviye + farklı sözcük türü (komşu türler)
        //  3) komşu CEFR seviyesi + aynı sözcük türü
        //  4) komşu CEFR seviyesi + herhangi tür (son çare — yine seviye komşuluğu korunur)
        var group = string.IsNullOrWhiteSpace(word.SemanticGroup) ? null : Normalize(word.SemanticGroup);
        var tiers = new List<Func<PoolItem, bool>>
        {
            p => group != null && p.Level == level
                 && p.SemanticGroup != null && Normalize(p.SemanticGroup) == group,
            p => p.Level == level && SamePos(p.PartOfSpeech, word.PartOfSpeech),
            p => p.Level == level && !SamePos(p.PartOfSpeech, word.PartOfSpeech),
            p => p.Level != level && SamePos(p.PartOfSpeech, word.PartOfSpeech),
            p => p.Level != level,
        };

        foreach (var tier in tiers)
        {
            if (chosen.Count >= OptionsPerQuestion - 1) break;

            var candidates = pool
                .Where(p => p.Id != word.Id && tier(p))
                .OrderBy(_ => Random.Shared.Next())
                .ToList();

            foreach (var c in candidates)
            {
                if (chosen.Count >= OptionsPerQuestion - 1) break;
                var norm = Normalize(c.Meaning);
                if (used.Add(norm)) chosen.Add(c.Meaning);
            }
        }

        return chosen;
    }

    private static VocabQuestionDto BuildQuestion(EnglishVocabWord word, List<string> distractors)
    {
        var options = new List<string>(OptionsPerQuestion) { word.TurkishMeaning };
        options.AddRange(distractors);

        // Şıkları karıştır.
        for (var i = options.Count - 1; i > 0; i--)
        {
            var j = Random.Shared.Next(i + 1);
            (options[i], options[j]) = (options[j], options[i]);
        }

        var correctIndex = options.IndexOf(word.TurkishMeaning);
        var correctLetter = ((char)('A' + correctIndex)).ToString();

        return new VocabQuestionDto
        {
            Id              = word.Id,
            EnglishWord     = word.EnglishWord,
            OptionA         = options[0],
            OptionB         = options[1],
            OptionC         = options[2],
            OptionD         = options[3],
            CorrectAnswer   = correctLetter,
            ExampleSentence = word.ExampleSentence,
        };
    }

    // ── Helpers ────────────────────────────────────────────────────────────────

    private static string? NormalizeLevel(string? level)
    {
        if (string.IsNullOrWhiteSpace(level)) return null;
        var upper = level.Trim().ToUpperInvariant();
        return Array.IndexOf(CefrOrder, upper) >= 0 ? upper : null;
    }

    private static IEnumerable<string> NeighborLevels(string level)
    {
        var idx = Array.IndexOf(CefrOrder, level);
        if (idx < 0) yield break;
        if (idx > 0) yield return CefrOrder[idx - 1];
        if (idx < CefrOrder.Length - 1) yield return CefrOrder[idx + 1];
    }

    private static bool SamePos(string a, string b)
        => string.Equals(a?.Trim(), b?.Trim(), StringComparison.OrdinalIgnoreCase);

    private static string Normalize(string meaning)
        => (meaning ?? string.Empty).Trim().ToLowerInvariant();

    private sealed class PoolItem
    {
        public int     Id            { get; init; }
        public string  Meaning       { get; init; } = string.Empty;
        public string  PartOfSpeech  { get; init; } = string.Empty;
        public string  Level         { get; init; } = string.Empty;
        public string? SemanticGroup { get; init; }
    }
}
