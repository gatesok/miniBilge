using MiniBilge.Application.DTOs.Flashcard;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class FlashcardService : IFlashcardService
{
    private const int FirstCompletionStarReward = 25;

    private readonly IFlashcardRepository _flashcardRepository;
    private readonly IChildProfileRepository _childProfileRepository;

    public FlashcardService(
        IFlashcardRepository flashcardRepository,
        IChildProfileRepository childProfileRepository)
    {
        _flashcardRepository = flashcardRepository;
        _childProfileRepository = childProfileRepository;
    }

    public async Task<IEnumerable<FlashcardDeckDto>> GetDecksByLevelAsync(int level, Guid childProfileId)
    {
        var decks = await _flashcardRepository.GetDecksByLevelAsync((EnglishLevel)level);
        var result = new List<FlashcardDeckDto>();

        foreach (var deck in decks)
        {
            var learnedCount = await _flashcardRepository.GetLearnedCountAsync(childProfileId, deck.Id);
            result.Add(new FlashcardDeckDto
            {
                Id = deck.Id,
                Title = deck.Title,
                Level = (int)deck.Level,
                EpisodeId = deck.EpisodeId,
                TotalCards = deck.Cards.Count,
                LearnedCount = learnedCount
            });
        }

        return result;
    }

    public async Task<IEnumerable<FlashcardDto>> GetCardsAsync(Guid deckId, Guid childProfileId)
    {
        var deck = await _flashcardRepository.GetDeckWithCardsAsync(deckId);
        if (deck is null) return Enumerable.Empty<FlashcardDto>();

        var progresses = await _flashcardRepository.GetProgressAsync(childProfileId, deckId);
        var progressMap = progresses.ToDictionary(p => p.FlashcardId);

        return deck.Cards.Select(card =>
        {
            progressMap.TryGetValue(card.Id, out var progress);
            return new FlashcardDto
            {
                Id = card.Id,
                DeckId = card.DeckId,
                FrontText = card.FrontText,
                BackText = card.BackText,
                ExampleSentence = card.ExampleSentence,
                AudioUrl = card.AudioUrl,
                DisplayOrder = card.DisplayOrder,
                IsLearned = progress?.IsLearned ?? false,
                ReviewCount = progress?.ReviewCount ?? 0
            };
        });
    }

    public async Task<FlashcardDeckDto?> GetDeckByEpisodeAsync(Guid episodeId, Guid childProfileId)
    {
        var deck = await _flashcardRepository.GetDeckByEpisodeAsync(episodeId);
        if (deck is null) return null;

        var learnedCount = await _flashcardRepository.GetLearnedCountAsync(childProfileId, deck.Id);
        return new FlashcardDeckDto
        {
            Id = deck.Id,
            Title = deck.Title,
            Level = (int)deck.Level,
            EpisodeId = deck.EpisodeId,
            TotalCards = deck.Cards.Count,
            LearnedCount = learnedCount
        };
    }

    public async Task MarkCardAsync(Guid childProfileId, Guid flashcardId, bool isLearned)
    {
        await _flashcardRepository.UpsertProgressAsync(childProfileId, flashcardId, isLearned);
    }

    public async Task<FlashcardSessionResultDto> CompleteSessionAsync(Guid childProfileId, Guid deckId)
    {
        var deck = await _flashcardRepository.GetDeckWithCardsAsync(deckId);
        if (deck is null)
            return new FlashcardSessionResultDto { DeckId = deckId };

        var totalCards = deck.Cards.Count;
        var learnedCount = await _flashcardRepository.GetLearnedCountAsync(childProfileId, deckId);
        var isFirstCompletion = await _flashcardRepository.IsDeckFirstCompletionAsync(childProfileId, deckId);

        var starEarned = 0;
        if (isFirstCompletion && learnedCount == totalCards)
        {
            starEarned = FirstCompletionStarReward;
            var child = await _childProfileRepository.GetByIdAsync(childProfileId);
            if (child is not null)
            {
                child.TotalStars += starEarned;
                await _childProfileRepository.UpdateAsync(child);
            }
        }

        return new FlashcardSessionResultDto
        {
            DeckId = deckId,
            LearnedCount = learnedCount,
            TotalCards = totalCards,
            StarEarned = starEarned,
            IsFirstCompletion = isFirstCompletion
        };
    }
}
