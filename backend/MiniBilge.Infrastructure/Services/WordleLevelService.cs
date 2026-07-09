using System.Text;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.DTOs.WordleLevel;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public class WordleLevelService : IWordleLevelService
{
    private readonly ApplicationDbContext         _db;
    private readonly IHttpClientFactory           _http;
    private readonly ILogger<WordleLevelService>  _logger;

    // Her 5 seviyede 1 skip ticket kazanılır
    private const int SkipTicketEvery = 5;
    // Her 10 seviyede milestone (kart drop)
    private const int MilestoneEvery  = 10;

    public WordleLevelService(
        ApplicationDbContext        db,
        IHttpClientFactory          http,
        ILogger<WordleLevelService> logger)
    {
        _db     = db;
        _http   = http;
        _logger = logger;
    }

    // ── GetCurrentLevelAsync ──────────────────────────────────────────────────

    public async Task<WordleLevelStateDto> GetCurrentLevelAsync(Guid childProfileId)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        var attempt  = await _db.WordleLevelAttempts
            .FirstOrDefaultAsync(a =>
                a.ChildProfileId == childProfileId &&
                a.Level          == progress.CurrentLevel);

        return MapToStateDto(progress, attempt);
    }

    // ── GenerateWordAsync ─────────────────────────────────────────────────────

    public async Task<WordleLevelStateDto> GenerateWordAsync(Guid childProfileId)
    {
        var progress   = await GetOrCreateProgressAsync(childProfileId);
        var level      = progress.CurrentLevel;
        var wordLength = WordleLevelProgress.WordLengthForLevel(level);

        // Zaten bu seviyede kelime üretilmişse döndür
        // Hint null ise (eski kayıt) güncellemeye çalış
        var existing = await _db.WordleLevelAttempts
            .FirstOrDefaultAsync(a => a.ChildProfileId == childProfileId && a.Level == level);
        if (existing != null)
        {
            if (string.IsNullOrEmpty(existing.Hint))
            {
                // Hint eklenmiş olması için AI'dan sadece hint iste
                var hint = await GetHintFromAiAsync(existing.Word, level);
                if (hint != null)
                {
                    existing.Hint = hint;
                    _db.WordleLevelAttempts.Update(existing);
                    await _db.SaveChangesAsync();
                }
            }
            return MapToStateDto(progress, existing);
        }

        // Bu kullanıcının aynı uzunluktaki son 30 kelimesini çek (tekrar önleme)
        var forbidden = await _db.WordleLevelAttempts
            .Where(a => a.ChildProfileId == childProfileId && a.WordLength == wordLength)
            .OrderByDescending(a => a.Level)
            .Take(30)
            .Select(a => a.Word)
            .ToListAsync();

        // Kelime üret — DB çakışmasında 3 kez retry
        WordleLevelAttempt? attempt = null;
        for (var attempt_no = 0; attempt_no < 3; attempt_no++)
        {
            var generated = await GenerateWordFromAiAsync(level, wordLength, forbidden);
            if (generated == null) continue;

            var newAttempt = new WordleLevelAttempt
            {
                ChildProfileId = childProfileId,
                Level          = level,
                Word           = generated.Word.ToUpperInvariant().Trim(),
                Hint           = generated.Hint,
                WordLength     = wordLength,
                Guesses        = [],
                CreatedAt      = DateTime.UtcNow,
            };

            try
            {
                _db.WordleLevelAttempts.Add(newAttempt);
                await _db.SaveChangesAsync();
                attempt = newAttempt;
                break;
            }
            catch (DbUpdateException ex) when (ex.InnerException?.Message.Contains("uq_wordle_attempt") == true)
            {
                // DB UNIQUE çakışması — bu kelime bu kullanıcıya daha önce verilmiş
                _db.ChangeTracker.Clear();
                forbidden.Add(newAttempt.Word);
                _logger.LogWarning("[WordleLevel] DB uniqueness conflict for word {Word}, retrying...", newAttempt.Word);
            }
        }

        if (attempt == null)
            throw new InvalidOperationException("Kelime üretilemedi. Lütfen tekrar deneyin.");

        return MapToStateDto(progress, attempt);
    }

    // ── SubmitGuessAsync ──────────────────────────────────────────────────────

    public async Task<WordleLevelSubmitResponse> SubmitGuessAsync(
        Guid childProfileId, WordleLevelSubmitRequest request)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        var level    = progress.CurrentLevel;
        var attempt  = await _db.WordleLevelAttempts
            .FirstOrDefaultAsync(a => a.ChildProfileId == childProfileId && a.Level == level)
            ?? throw new InvalidOperationException("Önce kelime üretmelisiniz.");

        if (attempt.Solved || attempt.AttemptsUsed >= WordleLevelProgress.MaxAttemptsForLevel(level))
            throw new InvalidOperationException("Bu seviye zaten tamamlandı.");

        var guess   = request.Guess.ToUpperInvariant().Trim();
        var pattern = WordlePatternCalculator.Calculate(attempt.Word, guess);
        var solved  = WordlePatternCalculator.IsCorrect(pattern);

        attempt.Guesses.Add(new WordleGuess { Guess = guess, Pattern = pattern });
        attempt.AttemptsUsed++;
        attempt.Solved = solved;

        var maxAttempts = WordleLevelProgress.MaxAttemptsForLevel(level);
        var finished    = solved || attempt.AttemptsUsed >= maxAttempts;

        int starsEarned = 0;
        bool levelUp    = false;
        bool milestone  = false;

        if (finished)
        {
            attempt.CompletedAt = DateTime.UtcNow;
            if (solved)
            {
                starsEarned = Math.Max(1, maxAttempts + 1 - attempt.AttemptsUsed);
                attempt.StarsEarned = starsEarned;

                // Progress güncelle
                progress.TotalSolved++;
                progress.CurrentStreak++;
                if (progress.CurrentStreak > progress.BestStreak)
                    progress.BestStreak = progress.CurrentStreak;

                // Seviye atla
                progress.CurrentLevel++;
                if (progress.CurrentLevel > progress.HighestLevel)
                    progress.HighestLevel = progress.CurrentLevel;

                levelUp = true;

                // Milestone kontrolü (her 10 seviye)
                milestone = progress.CurrentLevel % MilestoneEvery == 1;

                // Skip ticket kazanma (her 5 seviyede)
                if (progress.CurrentLevel % SkipTicketEvery == 1)
                    progress.SkipTickets++;
            }
            else
            {
                progress.CurrentStreak = 0;
            }

            // TotalStars güncelle
            if (starsEarned > 0)
            {
                var child = await _db.Set<ChildProfile>().FindAsync(childProfileId);
                if (child != null) child.TotalStars += starsEarned;
            }
        }

        _db.WordleLevelAttempts.Update(attempt);
        _db.WordleLevelProgresses.Update(progress);
        await _db.SaveChangesAsync();

        // Paylaşım metni
        string? shareText = null;
        if (finished)
        {
            var lines = attempt.Guesses.Select(g => WordlePatternCalculator.ToEmojiString(g.Pattern));
            shareText = $"MiniBilge Kelime Oyunu Seviye {level} — " +
                        $"{(solved ? attempt.AttemptsUsed.ToString() : "X")}/{maxAttempts}\n" +
                        string.Join("\n", lines);
        }

        return new WordleLevelSubmitResponse
        {
            Pattern      = pattern,
            Solved       = solved,
            Finished     = finished,
            AttemptsLeft = Math.Max(0, maxAttempts - attempt.AttemptsUsed),
            StarsEarned  = starsEarned,
            Answer       = finished ? attempt.Word : null,
            ShareText    = shareText,
            LevelUp      = levelUp,
            Milestone    = milestone,
        };
    }

    // ── RetryLevelAsync ───────────────────────────────────────────────────────

    public async Task<WordleLevelStateDto> RetryLevelAsync(Guid childProfileId)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        var level    = progress.CurrentLevel;

        // Mevcut attempt'i sil (seviye değişmez)
        var existing = await _db.WordleLevelAttempts
            .FirstOrDefaultAsync(a => a.ChildProfileId == childProfileId && a.Level == level);
        if (existing != null)
        {
            _db.WordleLevelAttempts.Remove(existing);
            await _db.SaveChangesAsync();
        }

        // Yeni kelime üret (aynı seviye için)
        return await GenerateWordAsync(childProfileId);
    }

    // ── SkipLevelAsync ────────────────────────────────────────────────────────

    public async Task<WordleLevelStateDto> SkipLevelAsync(Guid childProfileId)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        if (progress.SkipTickets <= 0)
            throw new InvalidOperationException("Skip hakkınız bulunmuyor.");

        var attempt = await _db.WordleLevelAttempts
            .FirstOrDefaultAsync(a => a.ChildProfileId == childProfileId && a.Level == progress.CurrentLevel);

        if (attempt != null)
        {
            attempt.Skipped     = true;
            attempt.Finished    = true;
            attempt.CompletedAt = DateTime.UtcNow;
            _db.WordleLevelAttempts.Update(attempt);
        }

        progress.SkipTickets--;
        progress.CurrentStreak = 0;
        progress.CurrentLevel++;
        if (progress.CurrentLevel > progress.HighestLevel)
            progress.HighestLevel = progress.CurrentLevel;

        _db.WordleLevelProgresses.Update(progress);
        await _db.SaveChangesAsync();

        return await GetCurrentLevelAsync(childProfileId);
    }

    // ── GetStatsAsync ─────────────────────────────────────────────────────────

    public async Task<WordleLevelStatsDto> GetStatsAsync(Guid childProfileId)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        var solved   = await _db.WordleLevelAttempts
            .Where(a => a.ChildProfileId == childProfileId && a.Solved)
            .ToListAsync();

        var avg = solved.Count > 0 ? solved.Average(a => a.AttemptsUsed) : 0.0;

        return new WordleLevelStatsDto
        {
            CurrentLevel    = progress.CurrentLevel,
            HighestLevel    = progress.HighestLevel,
            TotalSolved     = progress.TotalSolved,
            CurrentStreak   = progress.CurrentStreak,
            BestStreak      = progress.BestStreak,
            SkipTickets     = progress.SkipTickets,
            AverageAttempts = Math.Round(avg, 1),
        };
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<WordleLevelProgress> GetOrCreateProgressAsync(Guid childProfileId)
    {
        var progress = await _db.WordleLevelProgresses
            .FirstOrDefaultAsync(p => p.ChildProfileId == childProfileId);

        if (progress != null) return progress;

        progress = new WordleLevelProgress
        {
            ChildProfileId = childProfileId,
            CreatedAt      = DateTime.UtcNow,
        };
        _db.WordleLevelProgresses.Add(progress);
        await _db.SaveChangesAsync();
        return progress;
    }

    private static WordleLevelStateDto MapToStateDto(
        WordleLevelProgress progress, WordleLevelAttempt? attempt)
    {
        var level = progress.CurrentLevel;
        return new WordleLevelStateDto
        {
            CurrentLevel  = level,
            HighestLevel  = progress.HighestLevel,
            WordLength    = WordleLevelProgress.WordLengthForLevel(level),
            MaxAttempts   = WordleLevelProgress.MaxAttemptsForLevel(level),
            AttemptsUsed  = attempt?.AttemptsUsed ?? 0,
            Hint          = attempt?.Hint,
            Solved        = attempt?.Solved ?? false,
            Finished      = attempt?.Solved == true || (attempt?.AttemptsUsed >= WordleLevelProgress.MaxAttemptsForLevel(level)),
            Skipped       = attempt?.Skipped ?? false,
            SkipTickets   = progress.SkipTickets,
            StarsEarned   = attempt?.StarsEarned ?? 0,
            Guesses       = attempt?.Guesses
                .Select(g => new WordleLevelGuessDto { Guess = g.Guess, Pattern = g.Pattern })
                .ToList() ?? [],
        };
    }

    // ── AI Kelime Üretimi ─────────────────────────────────────────────────────

    private async Task<string?> GetHintFromAiAsync(string word, int level)
    {
        // Kelime ve hint birlikte döndürülerek doğrulama yapılır
        var prompt = $$$"""
Türkçe '{{{word}}}' kelimesi için kısa bir ipucu yaz.
İpucu '{{{word}}}' kelimesini TANımlamalı, başka bir şeyi değil.
Max 5 kelime, Türkçe.

JSON döndür: {{"word":"{{{word}}}","hint":"ipucu metni"}}
""";
        try
        {
            var client   = _http.CreateClient("openai");
            var body     = new
            {
                model           = "gpt-4o-mini",
                messages        = new[] { new { role = "user", content = prompt } },
                response_format = new { type = "json_object" },
                max_tokens      = 50,
                temperature     = 0.3,
            };
            var json     = JsonSerializer.Serialize(body);
            var content  = new StringContent(json, Encoding.UTF8, "application/json");
            var response = await client.PostAsync("chat/completions", content);
            response.EnsureSuccessStatusCode();
            var raw = await response.Content.ReadAsStringAsync();
            using var doc = JsonDocument.Parse(raw);
            var inner = doc.RootElement
                .GetProperty("choices")[0]
                .GetProperty("message")
                .GetProperty("content")
                .GetString() ?? "{}";
            using var result = JsonDocument.Parse(inner);
            // Kelime doğrulaması — dönen word, beklenen ile eşleşmeli
            var returnedWord = result.RootElement.TryGetProperty("word", out var w)
                ? w.GetString()?.ToUpperInvariant().Trim()
                : null;
            if (returnedWord != word.ToUpperInvariant().Trim())
            {
                _logger.LogWarning("[WordleLevel] Hint word mismatch: expected {Expected}, got {Got}", word, returnedWord);
                return null;
            }
            return result.RootElement.TryGetProperty("hint", out var h)
                ? h.GetString()?.Trim()
                : null;
        }
        catch { return null; }
    }

    private sealed record GeneratedLevelWord(string Word, string? Hint);

    private async Task<GeneratedLevelWord?> GenerateWordFromAiAsync(
        int level, int wordLength, IList<string> forbidden)
    {
        var difficulty = WordleLevelProgress.DifficultyForLevel(level);
        var forbiddenStr = forbidden.Count > 0
            ? $"\n⛔ BU KULLANICIYA DAHA ÖNCE VERİLEN {wordLength} HARFLİ KELİMELER — BUNLARI ASLA KULLANMA:\n{string.Join(", ", forbidden)}\n"
            : string.Empty;

        var prompt = $$"""
Türkçe tam olarak {{wordLength}} harfli bir kelime üret.
Seviye: {{level}}. Zorluk: {{difficulty}}.
{{forbiddenStr}}
KRİTİK KURALLAR:
- Kelime TAM OLARAK {{wordLength}} harf olmalı (Ç,Ğ,İ,Ö,Ş,Ü her biri 1 harf sayılır)
- Kelime GERÇEK ve YAYGIN Türkçe sözlük kelimesi olmalı — uydurma, nadir veya arkaik kelime OLMASIN
- Fiil kökü, isim veya sıfat olabilir — ama herkes bilmeli
- Özel isim (insan adı, şehir, ülke) OLMAMALI
- Kısa ve doğru Türkçe ipucu ekle (max 6 kelime) — ipucu sadece bu kelime için geçerli olmalı
- Zorluk: Kolay=markette geçen kelimeler, Orta=orta öğretim düzeyi, Zor=üniversite düzeyi

Örnekler ({{wordLength}} harf):
- ARABA, KALEM, GÜZEL gibi gerçek kelimeler ✓
- BULU, KELI, AZAP gibi uydurma veya belirsiz kelimeler ✗

Yalnızca JSON döndür:
{"word":"KELIME","hint":"kısa ipucu"}
""";

        try
        {
            var client = _http.CreateClient("openai");
            var body   = new
            {
                model           = "gpt-4o-mini",
                messages        = new[]
                {
                    new { role = "system", content = "Türkçe kelime üretiyorsun. Sadece geçerli JSON döndür." },
                    new { role = "user",   content = prompt },
                },
                response_format = new { type = "json_object" },
                max_tokens      = 60,
                temperature     = 0.9,
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

            using var result = JsonDocument.Parse(raw);
            var word = result.RootElement.TryGetProperty("word", out var w) ? w.GetString() : null;
            var hint = result.RootElement.TryGetProperty("hint", out var h) ? h.GetString() : null;

            if (string.IsNullOrWhiteSpace(word)) return null;

            var upper = word.ToUpperInvariant().Trim();
            // Kelime uzunluğu kontrol
            if (upper.Length != wordLength) return null;

            // Hint güvenlik kontrolü: hint içinde kelime adı geçmemeli (spoiler)
            // ama hint "masa" için "kilo" gibi alakasız da olmamalı
            // Response word ile üretilen word eşleşmeli
            return new GeneratedLevelWord(upper, hint);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[WordleLevel] AI kelime üretimi başarısız. Level={Level}", level);
            return null;
        }
    }
}
