using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Card;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CardController : ControllerBase
{
    private readonly ICardRepository _cardRepo;
    private readonly ICardDropService _cardDropService;

    public CardController(ICardRepository cardRepo, ICardDropService cardDropService)
    {
        _cardRepo = cardRepo;
        _cardDropService = cardDropService;
    }

    /// <summary>
    /// Tüm kart tanımlarını döndürür.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var cards = await _cardRepo.GetAllActiveAsync();
        return Ok(cards.Select(c => new CollectibleCardDto
        {
            Id = c.Id,
            Name = c.Name,
            Description = c.Description,
            Series = c.Series,
            Rarity = c.Rarity,
            ImageAsset = c.ImageAsset,
            CardNumber = c.CardNumber,
        }).ToList());
    }

    /// <summary>
    /// Çocuğun koleksiyonunu, tüm kartlarla birleştirilmiş şekilde döndürür.
    /// </summary>
    [HttpGet("collection/{childId}")]
    public async Task<IActionResult> GetCollection(Guid childId)
    {
        var allCards = await _cardRepo.GetAllActiveAsync();
        var owned = await _cardRepo.GetCollectionByChildAsync(childId);
        var ownedMap = owned.ToDictionary(cc => cc.CardId, cc => cc);
        var economy = await _cardDropService.GetSummaryAsync(childId);

        var dtos = allCards.Select(c =>
        {
            ownedMap.TryGetValue(c.Id, out var ownedCard);
            return new CollectibleCardDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description,
                Series = c.Series,
                Rarity = c.Rarity,
                ImageAsset = c.ImageAsset,
                CardNumber = c.CardNumber,
                IsOwned = ownedCard != null,
                OwnedCount = ownedCard?.Count ?? 0,
                FirstEarnedAt = ownedCard?.FirstEarnedAt,
            };
        }).ToList();

        return Ok(new CardCollectionDto
        {
            TotalCards = allCards.Count,
            OwnedCount = owned.Count,
            Cards = dtos,
            ShardBalance = economy.ShardBalance,
            DailyRemaining = economy.DailyRemaining,
            DailyLimit = economy.DailyLimit,
            PityRemaining = economy.PityRemaining,
            EconomyStage = economy.Stage,
        });
    }

    [HttpGet("economy/{childId}")]
    public async Task<IActionResult> GetEconomy(Guid childId)
        => Ok(await _cardDropService.GetSummaryAsync(childId));

    [HttpPost("collection/{childId}/unlock/{cardId}")]
    public async Task<IActionResult> UnlockWithShards(Guid childId, Guid cardId)
    {
        try
        {
            return Ok(await _cardDropService.UnlockWithShardsAsync(childId, cardId));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
