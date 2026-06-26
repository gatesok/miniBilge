using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IFlashcardRepository
{
    // Deck sorgulama
    Task<IEnumerable<FlashcardDeck>> GetDecksByLevelAsync(EnglishLevel level);
    Task<FlashcardDeck?> GetDeckWithCardsAsync(Guid deckId);
    Task<FlashcardDeck?> GetDeckByEpisodeAsync(Guid episodeId);

    // Kart ilerleme
    Task<IEnumerable<FlashcardProgress>> GetProgressAsync(Guid childProfileId, Guid deckId);
    Task<FlashcardProgress?> GetCardProgressAsync(Guid childProfileId, Guid flashcardId);
    Task UpsertProgressAsync(Guid childProfileId, Guid flashcardId, bool isLearned);

    // Oturum istatistikleri
    Task<int> GetLearnedCountAsync(Guid childProfileId, Guid deckId);
    Task<bool> IsDeckFirstCompletionAsync(Guid childProfileId, Guid deckId);

    // Vocab Challenge: çocuğun belirli seviyede incelediği kartlar
    Task<IEnumerable<Flashcard>> GetReviewedFlashcardsByLevelAsync(Guid childProfileId, EnglishLevel level);

    // Pronunciation Coach: o seviyedeki flashcard örnek cümleleri
    Task<IEnumerable<string>> GetExampleSentencesByLevelAsync(EnglishLevel level, int count);
}
