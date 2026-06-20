namespace MiniBilge.Application.Interfaces.Services;

public interface ICardDropService
{
    /// <summary>
    /// Drop ihtimaline göre kart ver. Null = drop yok.
    /// source: 'quiz_complete' | 'correct_answer'
    /// </summary>
    Task<CardDropResult?> TryDropAsync(Guid childProfileId, string source);
}

public record CardDropResult(
    Guid CardId,
    string CardName,
    string Rarity,
    string ImageAsset,
    bool IsNew     // çocukta daha önce yoktu
);
