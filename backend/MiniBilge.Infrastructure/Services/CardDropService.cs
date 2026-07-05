using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Services;

public class CardDropService : ICardDropService
{
    // Grade uygun quiz: common kolay, nadirler zor. Toplam %100 — uygun quizde garantili kart.
    private static readonly Dictionary<string, double> EligibleDropRates = new()
    {
        ["common"]    = 0.65,
        ["rare"]      = 0.25,
        ["epic"]      = 0.08,
        ["legendary"] = 0.02,
    };

    // AI Quiz %90+ — kart garantili, common yok, rare/epic ağırlıklı
    private static readonly Dictionary<string, double> AiHighDropRates = new()
    {
        ["rare"]      = 0.55,
        ["epic"]      = 0.35,
        ["legendary"] = 0.10,
    };

    // AI Quiz %100 mükemmel — Epic veya Legendary garantili
    private static readonly Dictionary<string, double> AiPerfectDropRates = new()
    {
        ["epic"]      = 0.60,
        ["legendary"] = 0.40,
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

    public async Task<CardDropResult?> TryDropAsync(Guid childProfileId, string source, bool isGradeEligible = false)
    {
        try
        {
            // quiz_complete için grade eligibility zorunlu
            if (source == "quiz_complete" && !isGradeEligible)
            {
                _logger.LogDebug("[CARD] Child {ChildId} not grade-eligible, skipping drop", childProfileId);
                return null;
            }

            var rates = source switch
            {
                "quiz_complete"    => isGradeEligible ? EligibleDropRates : AnswerDropRates,
                "ai_quiz_high"     => AiHighDropRates,
                "ai_quiz_perfect"  => AiPerfectDropRates,
                _                  => AnswerDropRates,
            };

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
