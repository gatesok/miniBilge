using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Services;

public class CardDropService : ICardDropService
{
    // Ağırlıklı drop oranları — quiz tamamlama kaynağı
    private static readonly Dictionary<string, double> QuizDropRates = new()
    {
        ["common"]    = 0.60,
        ["rare"]      = 0.25,
        ["epic"]      = 0.12,
        ["legendary"] = 0.03,
    };

    // Doğru cevap başına drop şansı (çok düşük)
    private static readonly Dictionary<string, double> AnswerDropRates = new()
    {
        ["common"]    = 0.050,
        ["rare"]      = 0.015,
        ["epic"]      = 0.004,
        ["legendary"] = 0.001,
    };

    private readonly ICardRepository _cardRepo;
    private readonly ILogger<CardDropService> _logger;
    private static readonly Random _rng = new();

    public CardDropService(ICardRepository cardRepo, ILogger<CardDropService> logger)
    {
        _cardRepo = cardRepo;
        _logger = logger;
    }

    public async Task<CardDropResult?> TryDropAsync(Guid childProfileId, string source)
    {
        try
        {
            var rates = source == "quiz_complete" ? QuizDropRates : AnswerDropRates;

            // Hiç drop olmuyor mu?
            var totalChance = rates.Values.Sum();
            if (_rng.NextDouble() > totalChance) return null;

            // Hangi nadirlik seviyesi?
            var rarity = PickRarity(rates);

            // O nadirlikten rastgele kart seç
            var allCards = await _cardRepo.GetAllActiveAsync();
            var candidates = allCards.Where(c => c.Rarity == rarity).ToList();
            if (candidates.Count == 0) return null;

            var card = candidates[_rng.Next(candidates.Count)];
            var isNew = await _cardRepo.GetChildCardAsync(childProfileId, card.Id) == null;

            await _cardRepo.AddOrIncrementAsync(childProfileId, card.Id, source);

            _logger.LogInformation("[CARD] Child {ChildId} dropped {Rarity} card '{Name}' (source: {Source}, new: {IsNew})",
                childProfileId, rarity, card.Name, source, isNew);

            return new CardDropResult(card.Id, card.Name, card.Rarity, card.ImageAsset, isNew);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[CARD] Drop error for child {ChildId}", childProfileId);
            return null;
        }
    }

    private static string PickRarity(Dictionary<string, double> rates)
    {
        var roll = _rng.NextDouble() * rates.Values.Sum();
        var cumulative = 0.0;
        foreach (var (rarity, rate) in rates)
        {
            cumulative += rate;
            if (roll <= cumulative) return rarity;
        }
        return "common";
    }
}
