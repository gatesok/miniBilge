using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Wordle;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public class WordleService : IWordleService
{
    private readonly ApplicationDbContext   _db;
    private readonly IWordleAiRefillService _refill;

    private const int MaxAttempts = 6;

    public WordleService(ApplicationDbContext db, IWordleAiRefillService refill)
    {
        _db     = db;
        _refill = refill;
    }

    // ── GetTodayAsync ─────────────────────────────────────────────────────────

    public async Task<WordleTodayDto> GetTodayAsync(
        Guid childProfileId, string language = "tr")
    {
        var today      = DateOnly.FromDateTime(DateTime.UtcNow);
        var assignment = await GetOrAssignTodayWordAsync(today, language);
        var result     = await GetOrCreateResultAsync(childProfileId, today, assignment.WordPoolId);

        return MapToDto(today, result);
    }

    // ── SubmitGuessAsync ──────────────────────────────────────────────────────

    public async Task<SubmitGuessResponse> SubmitGuessAsync(
        Guid childProfileId, string language, SubmitGuessRequest request)
    {
        var today      = DateOnly.FromDateTime(DateTime.UtcNow);
        var assignment = await _db.DailyWordAssignments
            .Include(d => d.WordPool)
            .FirstOrDefaultAsync(d => d.Date == today && d.Language == language)
            ?? throw new InvalidOperationException("Bugün için kelime atanmamış.");

        var result = await GetOrCreateResultAsync(childProfileId, today, assignment.WordPoolId);

        if (result.Solved || result.AttemptsUsed >= MaxAttempts)
            throw new InvalidOperationException("Oyun zaten tamamlandı.");

        var guess = request.Guess.ToUpperInvariant().Trim();

        if (guess.Length != assignment.WordPool.Word.Length)
            throw new InvalidOperationException($"Tahmin {assignment.WordPool.Word.Length} harf olmalıdır.");

        var pattern = WordlePatternCalculator.Calculate(assignment.WordPool.Word, guess);
        var solved  = WordlePatternCalculator.IsCorrect(pattern);

        result.Guesses.Add(new WordleGuess { Guess = guess, Pattern = pattern });
        result.AttemptsUsed++;
        result.Solved = solved;

        var finished = solved || result.AttemptsUsed >= MaxAttempts;
        if (finished) result.CompletedAt = DateTime.UtcNow;

        // Yıldız hesabı — kaç denemede çözüldü (daha az = daha fazla yıldız)
        // 1.deneme=6⭐, 2=5⭐, 3=4⭐, 4=3⭐, 5=2⭐, 6=1⭐, çözülmedi=0
        var starsEarned = 0;
        if (solved)
        {
            starsEarned = Math.Max(1, MaxAttempts + 1 - result.AttemptsUsed);
            // TotalStars güncelle
            var child = await _db.Set<MiniBilge.Domain.Entities.ChildProfile>()
                .FindAsync(childProfileId);
            if (child != null)
            {
                child.TotalStars += starsEarned;
                _db.Update(child);
            }
        }

        _db.WordGuessResults.Update(result);
        await _db.SaveChangesAsync();

        string? shareText = null;
        if (finished)
        {
            var lines = result.Guesses
                .Select(g => WordlePatternCalculator.ToEmojiString(g.Pattern));
            shareText = $"MiniBilge Wordle {today:dd.MM.yyyy} - " +
                        $"{(solved ? result.AttemptsUsed.ToString() : "X")}/{MaxAttempts}\n" +
                        string.Join("\n", lines);
        }

        return new SubmitGuessResponse
        {
            Pattern      = pattern,
            Solved       = solved,
            Finished     = finished,
            AttemptsLeft = Math.Max(0, MaxAttempts - result.AttemptsUsed),
            Answer       = finished ? assignment.WordPool.Word : null,
            ShareText    = shareText,
            StarsEarned  = starsEarned,
        };
    }

    // ── GetStatsAsync ─────────────────────────────────────────────────────────

    public async Task<WordleStatsDto> GetStatsAsync(
        Guid childProfileId, string language = "tr")
    {
        var results = await _db.WordGuessResults
            .Where(r => r.ChildProfileId == childProfileId)
            .Include(r => r.WordPool)
            .Where(r => r.WordPool.Language == language)
            .OrderByDescending(r => r.Date)
            .ToListAsync();

        var totalPlayed = results.Count(r => r.Solved || r.AttemptsUsed >= MaxAttempts);
        var totalSolved = results.Count(r => r.Solved);

        // Streak hesabı
        var today     = DateOnly.FromDateTime(DateTime.UtcNow);
        var streak    = 0;
        var bestStreak= 0;
        var cur       = today;
        foreach (var r in results.Where(r => r.Solved).OrderByDescending(r => r.Date))
        {
            if (r.Date == cur || r.Date == cur.AddDays(-1))
            {
                streak++;
                bestStreak = Math.Max(bestStreak, streak);
                cur = r.Date.AddDays(-1);
            }
            else break;
        }

        var solvedResults = results.Where(r => r.Solved).ToList();
        var avgAttempts   = solvedResults.Count > 0
            ? solvedResults.Average(r => r.AttemptsUsed)
            : 0.0;

        var guessDist = Enumerable.Range(1, MaxAttempts)
            .ToDictionary(i => i, i => solvedResults.Count(r => r.AttemptsUsed == i));

        return new WordleStatsDto
        {
            TotalPlayed      = totalPlayed,
            TotalSolved      = totalSolved,
            CurrentStreak    = streak,
            BestStreak       = bestStreak,
            AverageAttempts  = Math.Round(avgAttempts, 1),
            GuessDist        = guessDist,
        };
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<DailyWordAssignment> GetOrAssignTodayWordAsync(
        DateOnly today, string language)
    {
        var existing = await _db.DailyWordAssignments
            .Include(d => d.WordPool)
            .FirstOrDefaultAsync(d => d.Date == today && d.Language == language);

        if (existing != null) return existing;

        // Henüz kullanılmamış bir kelime seç (rastgelelik için GUID sıralaması)
        var word = await _db.WordPool
            .Where(w => w.Language == language && w.UsedOn == null)
            .OrderBy(w => w.Id)  // Pseudo-random — stable per day
            .FirstOrDefaultAsync()
            ?? throw new InvalidOperationException("Kelime havuzu boş! Lütfen yönetici ile iletişime geçin.");

        word.UsedOn = today;
        var assignment = new DailyWordAssignment
        {
            Date       = today,
            WordPoolId = word.Id,
            Language   = language,
            CreatedAt  = DateTime.UtcNow,
        };

        _db.DailyWordAssignments.Add(assignment);
        await _db.SaveChangesAsync();
        assignment.WordPool = word;

        // Havuz azaldıysa arka planda doldurmayı tetikle (fire-and-forget)
        _ = Task.Run(() => _refill.RefillIfNeededAsync(language));

        return assignment;
    }

    private async Task<WordGuessResult> GetOrCreateResultAsync(
        Guid childProfileId, DateOnly today, Guid wordPoolId)
    {
        var result = await _db.WordGuessResults
            .FirstOrDefaultAsync(r => r.ChildProfileId == childProfileId && r.Date == today);

        if (result != null) return result;

        result = new WordGuessResult
        {
            ChildProfileId = childProfileId,
            Date           = today,
            WordPoolId     = wordPoolId,
            Guesses        = new List<WordleGuess>(),
            CreatedAt      = DateTime.UtcNow,
        };

        _db.WordGuessResults.Add(result);
        await _db.SaveChangesAsync();
        return result;
    }

    private static WordleTodayDto MapToDto(DateOnly today, WordGuessResult result)
    {
        var finished = result.Solved || result.AttemptsUsed >= MaxAttempts;
        return new WordleTodayDto
        {
            Date            = today,
            WordLength      = 5,
            MaxAttempts     = MaxAttempts,
            AttemptsUsed    = result.AttemptsUsed,
            Solved          = result.Solved,
            Finished        = finished,
            PreviousGuesses = result.Guesses
                .Select(g => new WordleGuessDto { Guess = g.Guess, Pattern = g.Pattern })
                .ToList(),
        };
    }
}
