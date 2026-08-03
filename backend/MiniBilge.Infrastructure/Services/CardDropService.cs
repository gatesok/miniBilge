using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

public class CardDropService : ICardDropService
{
    private const int DailyLimit = 5;
    private readonly ICardRepository _cardRepo;
    private readonly ApplicationDbContext _db;
    private readonly ILogger<CardDropService> _logger;

    public CardDropService(
        ICardRepository cardRepo,
        ApplicationDbContext db,
        ILogger<CardDropService> logger)
    {
        _cardRepo = cardRepo;
        _db = db;
        _logger = logger;
    }

    public async Task<CardDropResult?> TryDropAsync(
        Guid childProfileId,
        string source,
        bool isGradeEligible = false,
        int successPercent = 100,
        string? difficulty = null,
        string? idempotencyKey = null)
    {
        try
        {
            if (source == "quiz_complete" && !isGradeEligible) return null;

            if (!string.IsNullOrWhiteSpace(idempotencyKey) &&
                await _db.CardEconomyEvents.AnyAsync(x =>
                    x.ChildProfileId == childProfileId &&
                    x.IdempotencyKey == idempotencyKey))
            {
                _logger.LogWarning("[CARD] Duplicate reward request ignored: {Key}", idempotencyKey);
                return null;
            }

            var allCards = await _cardRepo.GetAllActiveAsync();
            var owned = await _cardRepo.GetCollectionByChildAsync(childProfileId);
            var ownedIds = owned.Select(x => x.CardId).ToHashSet();
            var state = await GetOrCreateStateAsync(childProfileId);
            ResetDailyIfNeeded(state);

            var stage = GetStage(owned.Count, allCards.Count);
            var pityThreshold = GetPityThreshold(stage);
            var pityForced = state.AttemptsSinceDrop >= pityThreshold - 1;
            var newCardForced = state.DuplicatesSinceNew >= 2 && owned.Count < allCards.Count;
            var baseRate = GetDropRate(stage, source, successPercent, difficulty);

            if (state.DailyCardsEarned >= DailyLimit)
            {
                await LogEvent(childProfileId, null, source, stage, "daily_limit",
                    baseRate, false, false, 0, idempotencyKey);
                await _db.SaveChangesAsync();
                return null;
            }

            if (!pityForced && Random.Shared.NextDouble() > baseRate)
            {
                state.AttemptsSinceDrop++;
                state.UpdatedAt = DateTime.UtcNow;
                await LogEvent(childProfileId, null, source, stage, "no_drop",
                    baseRate, false, false, 0, idempotencyKey);
                await _db.SaveChangesAsync();
                return null;
            }

            var rarity = PickRarity(stage, successPercent, difficulty);
            var rarityCards = allCards.Where(x => x.Rarity == rarity).ToList();
            if (rarityCards.Count == 0) rarityCards = allCards;

            var unowned = rarityCards.Where(x => !ownedIds.Contains(x.Id)).ToList();
            var allUnowned = allCards.Where(x => !ownedIds.Contains(x.Id)).ToList();
            CollectibleCard card;
            if (newCardForced && allUnowned.Count > 0)
            {
                card = allUnowned[Random.Shared.Next(allUnowned.Count)];
            }
            else if (Random.Shared.NextDouble() < NewCardWeight(stage) &&
                unowned.Count > 0)
            {
                card = unowned[Random.Shared.Next(unowned.Count)];
            }
            else
            {
                card = rarityCards[Random.Shared.Next(rarityCards.Count)];
            }

            var isNew = !ownedIds.Contains(card.Id);
            var shards = isNew ? 0 : ShardsFor(card.Rarity);
            await _cardRepo.AddOrIncrementAsync(childProfileId, card.Id, source);

            state.AttemptsSinceDrop = 0;
            state.DuplicatesSinceNew = isNew ? 0 : state.DuplicatesSinceNew + 1;
            state.ShardBalance += shards;
            state.DailyCardsEarned++;
            state.UpdatedAt = DateTime.UtcNow;
            await LogEvent(childProfileId, card.Id, source, stage,
                isNew ? "new_card" : "duplicate", baseRate, pityForced || newCardForced,
                !isNew, shards, idempotencyKey);
            await _db.SaveChangesAsync();

            return new CardDropResult(
                card.Id, card.Name, card.Rarity, card.ImageAsset, isNew,
                shards, state.ShardBalance, DailyLimit - state.DailyCardsEarned,
                pityThreshold, stage, pityForced || newCardForced);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[CARD] Drop error for child {ChildId}", childProfileId);
            return null;
        }
    }

    public async Task<CardEconomySummary> GetSummaryAsync(Guid childProfileId)
    {
        var state = await GetOrCreateStateAsync(childProfileId);
        ResetDailyIfNeeded(state);
        var total = await _db.CollectibleCards.CountAsync(x => x.IsActive && !x.IsDeleted);
        var unique = await _db.ChildCards.CountAsync(x => x.ChildProfileId == childProfileId);
        var stage = GetStage(unique, total);
        await _db.SaveChangesAsync();
        return new CardEconomySummary(
            state.ShardBalance,
            Math.Max(0, DailyLimit - state.DailyCardsEarned),
            DailyLimit,
            Math.Max(0, GetPityThreshold(stage) - state.AttemptsSinceDrop),
            unique,
            total,
            stage);
    }

    public async Task<CardDropResult> UnlockWithShardsAsync(Guid childProfileId, Guid cardId)
    {
        var card = await _db.CollectibleCards.FirstOrDefaultAsync(x =>
            x.Id == cardId && x.IsActive && !x.IsDeleted)
            ?? throw new InvalidOperationException("Kart bulunamadı.");
        if (await _db.ChildCards.AnyAsync(x =>
                x.ChildProfileId == childProfileId && x.CardId == cardId))
            throw new InvalidOperationException("Bu kart zaten koleksiyonunda.");

        var state = await GetOrCreateStateAsync(childProfileId);
        var cost = ShardCost(card.Rarity);
        if (state.ShardBalance < cost)
            throw new InvalidOperationException($"Bu kart için {cost} kart parçası gerekiyor.");

        state.ShardBalance -= cost;
        state.DuplicatesSinceNew = 0;
        state.UpdatedAt = DateTime.UtcNow;
        await _cardRepo.AddOrIncrementAsync(childProfileId, card.Id, "shard_unlock");
        var total = await _db.CollectibleCards.CountAsync(x => x.IsActive && !x.IsDeleted);
        var unique = await _db.ChildCards.CountAsync(x => x.ChildProfileId == childProfileId);
        var stage = GetStage(unique, total);
        await LogEvent(childProfileId, card.Id, "shard_unlock", stage, "shard_unlock",
            1, true, false, -cost, $"shard:{childProfileId}:{cardId}");
        await _db.SaveChangesAsync();

        return new CardDropResult(card.Id, card.Name, card.Rarity, card.ImageAsset,
            true, -cost, state.ShardBalance,
            Math.Max(0, DailyLimit - state.DailyCardsEarned),
            Math.Max(0, GetPityThreshold(stage) - state.AttemptsSinceDrop), stage, true);
    }

    private async Task<CardEconomyState> GetOrCreateStateAsync(Guid childProfileId)
    {
        var state = await _db.CardEconomyStates
            .FirstOrDefaultAsync(x => x.ChildProfileId == childProfileId);
        if (state != null) return state;
        state = new CardEconomyState
        {
            Id = Guid.NewGuid(),
            ChildProfileId = childProfileId,
            DailyDate = DateOnly.FromDateTime(DateTime.UtcNow),
            UpdatedAt = DateTime.UtcNow,
        };
        _db.CardEconomyStates.Add(state);
        return state;
    }

    private static void ResetDailyIfNeeded(CardEconomyState state)
    {
        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        if (state.DailyDate == today) return;
        state.DailyDate = today;
        state.DailyCardsEarned = 0;
    }

    private Task LogEvent(Guid childId, Guid? cardId, string source, string stage,
        string outcome, double rate, bool guaranteed, bool duplicate, int shards,
        string? idempotencyKey)
    {
        _db.CardEconomyEvents.Add(new CardEconomyEvent
        {
            Id = Guid.NewGuid(), ChildProfileId = childId, CardId = cardId,
            Source = source, Stage = stage, Outcome = outcome, DropRate = rate,
            WasGuaranteed = guaranteed, WasDuplicate = duplicate,
            ShardsAwarded = shards, IdempotencyKey = idempotencyKey,
            CreatedAt = DateTime.UtcNow,
        });
        return Task.CompletedTask;
    }

    private static string GetStage(int unique, int total) =>
        unique <= 15 ? "starter" :
        unique <= 40 ? "growth" :
        unique <= Math.Min(64, total - 1) ? "mastery" : "finale";

    private static int GetPityThreshold(string stage) => stage switch
    {
        "starter" => 3, "growth" => 5, "mastery" => 7, _ => 8,
    };

    private static double NewCardWeight(string stage) => stage switch
    {
        "starter" => .90, "growth" => .65, "mastery" => .45, _ => .35,
    };

    private static double GetDropRate(string stage, string source, int success, string? difficulty)
    {
        var rate = stage switch
        {
            "starter" => .80, "growth" => .55, "mastery" => .35, _ => .20,
        };
        if (source == "ai_quiz_perfect") rate = Math.Max(rate, .80);
        else if (source == "ai_quiz_high") rate = Math.Max(rate, .65);
        else if (source == "wordle_milestone") rate += .10;
        rate += success >= 90 ? .10 : success >= 75 ? .04 : success < 60 ? -.12 : 0;
        rate += difficulty?.ToLowerInvariant() switch
        {
            "hard" or "zor" => .08,
            "medium" or "orta" => .03,
            _ => 0,
        };
        return Math.Clamp(rate, .08, .90);
    }

    private static string PickRarity(string stage, int success, string? difficulty)
    {
        var rareBoost = stage is "mastery" or "finale" ? .10 : 0;
        if (success >= 90) rareBoost += .08;
        if (difficulty?.ToLowerInvariant() is "hard" or "zor") rareBoost += .05;
        var roll = Random.Shared.NextDouble();
        if (roll < .02 + rareBoost / 5) return "legendary";
        if (roll < .10 + rareBoost / 2) return "epic";
        if (roll < .35 + rareBoost) return "rare";
        return "common";
    }

    private static int ShardsFor(string rarity) => rarity switch
    {
        "rare" => 12, "epic" => 30, "legendary" => 80, _ => 5,
    };

    private static int ShardCost(string rarity) => rarity switch
    {
        "rare" => 180, "epic" => 400, "legendary" => 900, _ => 80,
    };
}
