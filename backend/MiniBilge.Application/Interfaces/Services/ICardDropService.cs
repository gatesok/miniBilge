namespace MiniBilge.Application.Interfaces.Services;

public interface ICardDropService
{
    /// <summary>
    /// Drop ihtimaline göre kart ver. Null = drop yok.
    /// source: 'quiz_complete' | 'correct_answer'
    /// isGradeEligible: çocuğun sınıf seviyesine uygun quiz mi?
    /// </summary>
    Task<CardDropResult?> TryDropAsync(
        Guid childProfileId,
        string source,
        bool isGradeEligible = false,
        int successPercent = 100,
        string? difficulty = null,
        string? idempotencyKey = null);

    Task<CardEconomySummary> GetSummaryAsync(Guid childProfileId);
    Task<CardDropResult> UnlockWithShardsAsync(Guid childProfileId, Guid cardId);
}

public record CardDropResult(
    Guid CardId,
    string CardName,
    string Rarity,
    string ImageAsset,
    bool IsNew,
    int ShardsAwarded = 0,
    int ShardBalance = 0,
    int DailyRemaining = 0,
    int PityRemaining = 0,
    string Stage = "starter",
    bool WasGuaranteed = false
);

public record CardEconomySummary(
    int ShardBalance,
    int DailyRemaining,
    int DailyLimit,
    int PityRemaining,
    int UniqueCards,
    int TotalCards,
    string Stage
);
