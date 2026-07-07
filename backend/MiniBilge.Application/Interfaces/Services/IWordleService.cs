using MiniBilge.Application.DTOs.Wordle;

namespace MiniBilge.Application.Interfaces.Services;

public interface IWordleService
{
    /// <summary>Bugünün oyun durumunu döner. Henüz atama yoksa kelimeyi atar.</summary>
    Task<WordleTodayDto> GetTodayAsync(Guid childProfileId, string language = "tr");

    /// <summary>
    /// Tahmin gönderir, pattern hesaplar, kaydeder.
    /// Validation hatası için InvalidOperationException fırlatır.
    /// </summary>
    Task<SubmitGuessResponse> SubmitGuessAsync(
        Guid childProfileId, string language, SubmitGuessRequest request);

    /// <summary>Kullanıcının Wordle istatistiklerini döner.</summary>
    Task<WordleStatsDto> GetStatsAsync(Guid childProfileId, string language = "tr");
}
