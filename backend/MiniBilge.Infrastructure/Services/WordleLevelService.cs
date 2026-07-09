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

        // Bu kullanıcının aynı uzunluktaki son 200 kelimesini forbidden olarak al
        // (200 kelime = ~200 seviye oynanması — pratik üst sınır)
        var forbidden = await _db.WordleLevelAttempts
            .Where(a => a.ChildProfileId == childProfileId && a.WordLength == wordLength)
            .OrderByDescending(a => a.Level)
            .Take(200)
            .Select(a => a.Word)
            .ToListAsync();

        // DB havuzundan kelime çek
        var targetDifficulty = DifficultyForLevelInt(level);
        var poolWord = await GetWordFromPoolAsync(wordLength, targetDifficulty, forbidden);

        // Havuzda uygun kelime yoksa AI fallback
        if (poolWord == null)
        {
            _logger.LogWarning("[WordleLevel] Pool empty for length={L} diff={D}, falling back to AI", wordLength, targetDifficulty);
            poolWord = await GenerateWordFromAiAsync(level, wordLength, forbidden, 0)
                    ?? await GenerateWordFromAiAsync(level, wordLength, forbidden, 1)
                    ?? await GenerateWordFromAiAsync(level, wordLength, forbidden, 2);
        }

        if (poolWord == null)
            throw new InvalidOperationException("Kelime üretilemedi. Lütfen tekrar deneyin.");

        WordleLevelAttempt? attempt = null;
        var newAttempt = new WordleLevelAttempt
        {
            ChildProfileId = childProfileId,
            Level          = level,
            Word           = poolWord.Word,
            Hint           = poolWord.Hint,
            WordLength     = wordLength,
            Guesses        = [],
            CreatedAt      = DateTime.UtcNow,
        };

        try
        {
            _db.WordleLevelAttempts.Add(newAttempt);
            await _db.SaveChangesAsync();
            attempt = newAttempt;

            // Havuz kullanım sayacını artır
            var poolEntry = await _db.WordleLevelPool
                .FirstOrDefaultAsync(p => p.Word == poolWord.Word && p.Language == "tr");
            if (poolEntry != null)
            {
                poolEntry.UsedCount++;
                await _db.SaveChangesAsync();
            }
        }
        catch (DbUpdateException ex) when (ex.InnerException?.Message.Contains("uq_wordle_attempt") == true)
        {
            _db.ChangeTracker.Clear();
            _logger.LogWarning("[WordleLevel] DB conflict for word {W}, retrying with AI", newAttempt.Word);
            // Son çare: AI'dan al
            var aiWord = await GenerateWordFromAiAsync(level, wordLength, [..forbidden, newAttempt.Word], 0);
            if (aiWord != null)
            {
                var aiAttempt = new WordleLevelAttempt
                {
                    ChildProfileId = childProfileId,
                    Level          = level,
                    Word           = aiWord.Word,
                    Hint           = aiWord.Hint,
                    WordLength     = wordLength,
                    Guesses        = [],
                    CreatedAt      = DateTime.UtcNow,
                };
                _db.WordleLevelAttempts.Add(aiAttempt);
                await _db.SaveChangesAsync();
                attempt = aiAttempt;
            }
        }

        if (attempt == null)
            throw new InvalidOperationException("Kelime kaydedilemedi. Lütfen tekrar deneyin.");

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

    // ── UseJokerAsync ─────────────────────────────────────────────────────────

    public async Task<JokerResponse> UseJokerAsync(Guid childProfileId)
    {
        var progress = await GetOrCreateProgressAsync(childProfileId);
        if (progress.JokerTickets <= 0)
            throw new InvalidOperationException("Joker hakkınız kalmadı.");

        var attempt = await _db.WordleLevelAttempts.FirstOrDefaultAsync(a =>
            a.ChildProfileId == childProfileId &&
            a.Level          == progress.CurrentLevel);

        if (attempt == null || string.IsNullOrEmpty(attempt.Word))
            throw new InvalidOperationException("Aktif bir kelime oyunu bulunamadı.");

        if (attempt.Solved || attempt.Finished || attempt.Skipped)
            throw new InvalidOperationException("Bu seviye zaten tamamlandı.");

        var word = attempt.Word.ToUpperInvariant();

        // Zaten doğru olarak tahmin edilmiş pozisyonlar
        var correctPositions = new HashSet<int>();
        foreach (var g in attempt.Guesses)
        {
            for (var i = 0; i < g.Pattern.Length; i++)
                if (g.Pattern[i] == "correct")
                    correctPositions.Add(i);
        }

        // Zaten joker ile açılmış pozisyonlar
        var revealedPositions = attempt.JokerReveals.Select(j => j.Position).ToHashSet();

        // Henüz açılmamış pozisyonlar
        var available = Enumerable.Range(0, word.Length)
            .Where(i => !correctPositions.Contains(i) && !revealedPositions.Contains(i))
            .ToList();

        if (available.Count == 0)
            throw new InvalidOperationException("Tüm harfler zaten açılmış.");

        var rnd      = Random.Shared.Next(available.Count);
        var position = available[rnd];
        var letter   = word[position].ToString();

        attempt.JokerReveals.Add(new MiniBilge.Domain.Entities.JokerReveal
        {
            Position = position,
            Letter   = letter,
        });
        progress.JokerTickets--;

        _db.WordleLevelAttempts.Update(attempt);
        _db.WordleLevelProgresses.Update(progress);
        await _db.SaveChangesAsync();

        return new JokerResponse
        {
            Position         = position,
            Letter           = letter,
            JokerTicketsLeft = progress.JokerTickets,
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
            JokerTickets  = progress.JokerTickets,
            StarsEarned   = attempt?.StarsEarned ?? 0,
            Guesses       = attempt?.Guesses
                .Select(g => new WordleLevelGuessDto { Guess = g.Guess, Pattern = g.Pattern })
                .ToList() ?? [],
            JokerReveals  = attempt?.JokerReveals
                .Select(j => new JokerRevealDto { Position = j.Position, Letter = j.Letter })
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

    private async Task<GeneratedLevelWord?> GetWordFromPoolAsync(
        int wordLength, int difficulty, ICollection<string> forbidden)
    {
        // Önce hedef zorluğa bak, bulamazsa komşu zorluğa genişlet
        for (var diffSearch = 0; diffSearch <= 2; diffSearch++)
        {
            var minDiff = Math.Max(1, difficulty - diffSearch);
            var maxDiff = Math.Min(3, difficulty + diffSearch);

            // forbidden listesi DB tarafında WHERE NOT IN ile filtrelenir
            // Büyük listeler için de performanslı (EF Core bunu SQL subquery'e çevirir)
            var word = await _db.WordleLevelPool
                .Where(p => p.Language   == "tr"
                         && p.WordLength == wordLength
                         && p.Difficulty >= minDiff
                         && p.Difficulty <= maxDiff
                         && !forbidden.Contains(p.Word))
                .OrderBy(_ => Guid.NewGuid())  // Rastgele sıralama
                .FirstOrDefaultAsync();

            if (word != null)
                return new GeneratedLevelWord(word.Word, word.Hint);
        }

        // Tüm uzunluktaki kelimeler bittiyse (kullanıcı havuzu tüketti)
        _logger.LogWarning("[WordleLevel] Pool exhausted for length={L} diff={D} — all words used by this user!", wordLength, difficulty);
        return null;
    }

    private static int DifficultyForLevelInt(int level) => level switch
    {
        <= 10  => 1,
        <= 25  => 1,
        <= 50  => 2,
        <= 100 => 2,
        <= 150 => 3,
        _      => 3,
    };

    private static string? GetFallbackWord(int wordLength, ICollection<string> forbidden)
    {
        var pool = wordLength switch
        {
            4 => _fallback4,
            5 => _fallback5,
            6 => _fallback6,
            _ => _fallback7,
        };
        // Forbidden listesinde olmayan ilk kelimeyi döndür
        return pool.FirstOrDefault(w => !forbidden.Contains(w));
    }

    // Fallback kelime havuzları — AI başarısız olursa kullanılır
    private static readonly string[] _fallback4 =
    [
        "ARBA","KALEM","MASA","KAPI","YURT","DOST","GECE","HAVA","KAYA","DAĞLAR",
        "ÇARK","BORU","KÖMÜR","SARP","DÜZCE","TREN","OTLA","KAPI","YÜZÜK","TABAK",
        "TARAK","MAKAS","SEPET","TORBA","ÇATAL","HAVLU","DUVAR","PEMBE","TAVUK","KOYUN",
    ];

    private static readonly string[] _fallback5 =
    [
        "ARABA","KALEM","ÇANTA","EKMEK","GÜZEL","HAYAT","DÜNYA","ZAMAN","SABAH","HAFTA",
        "MEYVE","ARMUT","KAVUN","ŞEKER","BEYAZ","SALON","YATAK","DOLAP","PERDE","BANYO",
        "TEKNE","KANAT","ÇOCUK","BEBEK","KÖPEK","BULUT","GÜNEŞ","DENİZ","NEHİR","ORMAN",
        "DUMAN","YAŞAM","MÜZİK","KİTAP","RESİM","FENER","KEMER","YANAK","BİLEK","TOPUK",
    ];

    private static readonly string[] _fallback6 =
    [
        "ÇEŞME","BORSA","KREDİ","HESAP","HAVUZ","LİMAN","IRMAK","VATAN","GURUR","NAMUS",
        "AKTÖR","ROMAN","FİKİR","KOŞUL","BAŞKA","TEMEL","GÖRÜŞ","SEÇİM","GELİR","VERGİ",
        "BELGİ","DOSYA","EKRAN","KABLO","KURUL","KAYGI","ŞÜPHE","GÜREŞ","TENİS","KULİS",
    ];

    private static readonly string[] _fallback7 =
    [
        "ÖZGÜRLÜK","DOĞRULUK","YOLCULUK","GÜÇLÜLÜK","REFAH","SÜRÜM","MİRAS","GÖREV",
    ];

    private sealed record GeneratedLevelWord(string Word, string? Hint);

    private async Task<GeneratedLevelWord?> GenerateWordFromAiAsync(
        int level, int wordLength, IList<string> forbidden, int attemptNo = 0)
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
- Kelime GERÇEK, YAYGIN Türkçe sözlük kelimesi olmalı — uydurma OLMAMALI
- Özel isim (kişi adı, şehir, ülke) OLMAMALI
- Ç,Ğ,İ,Ö,Ş,Ü her biri ayrı 1 harf sayılır
- Zorluk: Kolay=markette geçen kelimeler, Orta=lise düzeyi, Zor=üniversite düzeyi

HARF SAYMA TALİMATI:
Kelimeyi seçmeden önce harflerini tek tek say, tam olarak {{wordLength}} harf olduğunu doğrula.
Eğer {{wordLength}} harf değilse başka kelime seç.

JSON döndür (letters dizisindeki eleman sayısı {{wordLength}} olmalı):
{
  "word": "KELİME",
  "letters": ["K","E","L","İ","M","E"],
  "hint": "kısa Türkçe ipucu (max 6 kelime)"
}
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
                max_tokens      = 120,  // letters dizisi için artırıldı
                temperature     = attemptNo == 0 ? 0.9 : (attemptNo == 1 ? 0.7 : 0.5), // Retry'da daha deterministik
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

            // 1. letters dizisi varsa o üzerinden uzunluk doğrula (daha güvenilir)
            if (result.RootElement.TryGetProperty("letters", out var lettersEl))
            {
                var letterCount = lettersEl.GetArrayLength();
                if (letterCount != wordLength)
                {
                    _logger.LogWarning("[WordleLevel] AI letters count mismatch: expected {E}, got {G} for word '{W}'",
                        wordLength, letterCount, upper);
                    return null;
                }
            }
            else
            {
                // letters yoksa string uzunluğuna bak
                if (upper.Length != wordLength) return null;
            }

            return new GeneratedLevelWord(upper, hint);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[WordleLevel] AI kelime üretimi başarısız. Level={Level}", level);
            return null;
        }
    }
}
