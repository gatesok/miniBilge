using System.Globalization;
using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Kelime geçerliliğini 3 katmanlı sırayla kontrol eder: kürasyonlu hedef havuzu (wordle_level_pool)
/// → yerel TDK cache (tdk_word_cache) → canlı TDK servisi (sozluk.gov.tr). TDK'ya ulaşılamazsa
/// kullanıcı cezalandırılmaz (fail-open).
/// </summary>
public class TurkishWordValidationService : ITurkishWordValidationService
{
    private static readonly CultureInfo TrCulture = new("tr-TR");

    private readonly ApplicationDbContext _db;
    private readonly IHttpClientFactory   _http;
    private readonly ILogger<TurkishWordValidationService> _logger;

    public TurkishWordValidationService(
        ApplicationDbContext db,
        IHttpClientFactory   http,
        ILogger<TurkishWordValidationService> logger)
    {
        _db     = db;
        _http   = http;
        _logger = logger;
    }

    public async Task<bool> IsValidWordAsync(string normalizedWord, CancellationToken ct = default)
    {
        var word = normalizedWord.Trim();
        if (word.Length == 0) return false;

        try
        {
            var inPool = await _db.WordleLevelPool
                .AnyAsync(p => p.Word == word && p.Language == "tr", ct);
            if (inPool) return true;

            var cached = await _db.TdkWordCache.FirstOrDefaultAsync(c => c.Word == word, ct);
            if (cached != null) return cached.IsValid;

            var tdkResult = await QueryTdkAsync(word, ct);
            if (tdkResult == null)
            {
                _logger.LogWarning("[TDK] {Word} doğrulanamadı (servise ulaşılamadı), fail-open uygulanıyor", word);
                return true;
            }

            var cacheEntry = new TdkWordCache
            {
                Word      = word,
                IsValid   = tdkResult.Value,
                CheckedAt = DateTime.UtcNow,
            };
            _db.TdkWordCache.Add(cacheEntry);
            try
            {
                await _db.SaveChangesAsync(ct);
            }
            catch (DbUpdateException)
            {
                // Eşzamanlı bir istek (ör. çift tıklama) aynı kelimeyi zaten cache'lemiş olabilir.
                // Bu entity'yi tracker'dan çıkarmazsak çağıranın sonraki SaveChangesAsync'i
                // aynı satırı tekrar eklemeye çalışıp yeniden patlar.
                _db.Entry(cacheEntry).State = EntityState.Detached;
            }

            return tdkResult.Value;
        }
        catch (Exception ex) when (ex is not OperationCanceledException)
        {
            // Doğrulama altyapısında beklenmeyen bir hata olursa oyunu bozma — fail-open.
            _logger.LogError(ex, "[TDK] {Word} doğrulanırken beklenmeyen hata, fail-open uygulanıyor", word);
            return true;
        }
    }

    /// <summary>TDK'ya sorar. Ulaşılamazsa/parse edilemezse null (fail-open sinyali) döner.</summary>
    private async Task<bool?> QueryTdkAsync(string word, CancellationToken ct)
    {
        try
        {
            var client = _http.CreateClient("tdk");
            var query  = word.ToLower(TrCulture);
            using var response = await client.GetAsync($"gts?ara={Uri.EscapeDataString(query)}", ct);
            if (!response.IsSuccessStatusCode) return null;

            var json = await response.Content.ReadAsStringAsync(ct);
            using var doc = JsonDocument.Parse(json);

            // {"error": "Sonuç bulunamadı"} → kelime TDK'da yok
            if (doc.RootElement.ValueKind != JsonValueKind.Array) return false;

            foreach (var item in doc.RootElement.EnumerateArray())
            {
                if (item.TryGetProperty("madde_duz", out var maddeDuz) &&
                    string.Equals(maddeDuz.GetString(), query, StringComparison.OrdinalIgnoreCase))
                {
                    return true;
                }
            }
            return false;
        }
        catch (Exception ex) when (ex is HttpRequestException or TaskCanceledException or JsonException)
        {
            _logger.LogWarning(ex, "[TDK] {Word} sorgusu başarısız", word);
            return null;
        }
    }
}
