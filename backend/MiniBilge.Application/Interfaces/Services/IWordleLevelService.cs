using MiniBilge.Application.DTOs.WordleLevel;

namespace MiniBilge.Application.Interfaces.Services;

public interface IWordleLevelService
{
    /// <summary>Kullanıcının mevcut seviyesini ve bu seviyedeki durum döner. Seviye yoksa oluşturur.</summary>
    Task<WordleLevelStateDto> GetCurrentLevelAsync(Guid childProfileId);

    /// <summary>Mevcut seviye için AI'dan yeni kelime üretir ve kaydeder.</summary>
    Task<WordleLevelStateDto> GenerateWordAsync(Guid childProfileId);

    /// <summary>Tahmin gönderir, pattern hesaplar, ödül verir.</summary>
    Task<WordleLevelSubmitResponse> SubmitGuessAsync(Guid childProfileId, WordleLevelSubmitRequest request);

    /// <summary>Seviyeyi pas geçer (skip ticket harcar).</summary>
    Task<WordleLevelStateDto> SkipLevelAsync(Guid childProfileId);

    /// <summary>Kullanıcının istatistiklerini döner.</summary>
    Task<WordleLevelStatsDto> GetStatsAsync(Guid childProfileId);
}
