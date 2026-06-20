using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Card;
using MiniBilge.Application.Interfaces.Repositories;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CardController : ControllerBase
{
    private readonly ICardRepository _cardRepo;

    public CardController(ICardRepository cardRepo)
    {
        _cardRepo = cardRepo;
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
        });
    }
}
