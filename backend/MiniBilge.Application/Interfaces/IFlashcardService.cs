using MiniBilge.Application.DTOs.Flashcard;

namespace MiniBilge.Application.Interfaces;

public interface IFlashcardService
{
    Task<IEnumerable<FlashcardDeckDto>> GetDecksByLevelAsync(int level, Guid childProfileId);
    Task<IEnumerable<FlashcardDto>> GetCardsAsync(Guid deckId, Guid childProfileId);
    Task<FlashcardDeckDto?> GetDeckByEpisodeAsync(Guid episodeId, Guid childProfileId);
    Task MarkCardAsync(Guid childProfileId, Guid flashcardId, bool isLearned);
    Task<FlashcardSessionResultDto> CompleteSessionAsync(Guid childProfileId, Guid deckId);
}
