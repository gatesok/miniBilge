using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class FlashcardRepository : IFlashcardRepository
{
    private readonly ApplicationDbContext _context;

    public FlashcardRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<FlashcardDeck>> GetDecksByLevelAsync(EnglishLevel level)
        => await _context.FlashcardDecks
            .Include(d => d.Cards.Where(c => c.IsActive && !c.IsDeleted))
            .Where(d => d.Level == level && d.IsActive && !d.IsDeleted)
            .OrderBy(d => d.DisplayOrder)
            .ToListAsync();

    public async Task<FlashcardDeck?> GetDeckWithCardsAsync(Guid deckId)
        => await _context.FlashcardDecks
            .Include(d => d.Cards
                .Where(c => c.IsActive && !c.IsDeleted)
                .OrderBy(c => c.DisplayOrder))
            .FirstOrDefaultAsync(d => d.Id == deckId && d.IsActive && !d.IsDeleted);

    public async Task<FlashcardDeck?> GetDeckByEpisodeAsync(Guid episodeId)
        => await _context.FlashcardDecks
            .Include(d => d.Cards
                .Where(c => c.IsActive && !c.IsDeleted)
                .OrderBy(c => c.DisplayOrder))
            .FirstOrDefaultAsync(d => d.EpisodeId == episodeId && d.IsActive && !d.IsDeleted);

    public async Task<IEnumerable<FlashcardProgress>> GetProgressAsync(Guid childProfileId, Guid deckId)
    {
        var cardIds = await _context.Flashcards
            .Where(c => c.DeckId == deckId && c.IsActive && !c.IsDeleted)
            .Select(c => c.Id)
            .ToListAsync();

        return await _context.FlashcardProgresses
            .Where(p => p.ChildProfileId == childProfileId && cardIds.Contains(p.FlashcardId))
            .ToListAsync();
    }

    public async Task<FlashcardProgress?> GetCardProgressAsync(Guid childProfileId, Guid flashcardId)
        => await _context.FlashcardProgresses
            .FirstOrDefaultAsync(p => p.ChildProfileId == childProfileId && p.FlashcardId == flashcardId);

    public async Task UpsertProgressAsync(Guid childProfileId, Guid flashcardId, bool isLearned)
    {
        var existing = await GetCardProgressAsync(childProfileId, flashcardId);

        if (existing is null)
        {
            _context.FlashcardProgresses.Add(new FlashcardProgress
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childProfileId,
                FlashcardId = flashcardId,
                IsLearned = isLearned,
                ReviewCount = 1,
                LastReviewedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow
            });
        }
        else
        {
            existing.IsLearned = isLearned;
            existing.ReviewCount++;
            existing.LastReviewedAt = DateTime.UtcNow;
            existing.UpdatedAt = DateTime.UtcNow;
        }

        await _context.SaveChangesAsync();
    }

    public async Task<int> GetLearnedCountAsync(Guid childProfileId, Guid deckId)
    {
        var cardIds = await _context.Flashcards
            .Where(c => c.DeckId == deckId && c.IsActive && !c.IsDeleted)
            .Select(c => c.Id)
            .ToListAsync();

        return await _context.FlashcardProgresses
            .CountAsync(p => p.ChildProfileId == childProfileId
                          && cardIds.Contains(p.FlashcardId)
                          && p.IsLearned);
    }

    public async Task<bool> IsDeckFirstCompletionAsync(Guid childProfileId, Guid deckId)
    {
        var totalCards = await _context.Flashcards
            .CountAsync(c => c.DeckId == deckId && c.IsActive && !c.IsDeleted);

        if (totalCards == 0) return false;

        var learnedCount = await GetLearnedCountAsync(childProfileId, deckId);

        // Tüm kartlar öğrenilmiş ama son işaret bu tur yapıldı mı?
        // ReviewCount == 1 olanlar bu oturumda ilk kez öğrenilen kartlardır
        var firstTimeLearnedCount = await _context.FlashcardProgresses
            .CountAsync(p => p.ChildProfileId == childProfileId
                          && _context.Flashcards
                              .Where(c => c.DeckId == deckId && c.IsActive && !c.IsDeleted)
                              .Select(c => c.Id)
                              .Contains(p.FlashcardId)
                          && p.IsLearned
                          && p.ReviewCount == 1);

        return learnedCount == totalCards && firstTimeLearnedCount > 0;
    }

    public async Task<IEnumerable<Flashcard>> GetReviewedFlashcardsByLevelAsync(Guid childProfileId, EnglishLevel level)
    {
        // Önce çocuğun incelediği (ReviewCount > 0) kartları seviyeye göre getir
        var reviewed = await _context.Flashcards
            .Include(f => f.Deck)
            .Where(f => f.Deck.Level == level
                     && f.IsActive && !f.IsDeleted
                     && _context.FlashcardProgresses.Any(p =>
                            p.ChildProfileId == childProfileId
                            && p.FlashcardId == f.Id
                            && p.ReviewCount > 0))
            .ToListAsync();

        // Yeterli kart yoksa o seviyedeki tüm aktif kartları döndür (fallback)
        if (reviewed.Count >= 3)
            return reviewed;

        return await _context.Flashcards
            .Include(f => f.Deck)
            .Where(f => f.Deck.Level == level && f.IsActive && !f.IsDeleted)
            .ToListAsync();
    }
}
