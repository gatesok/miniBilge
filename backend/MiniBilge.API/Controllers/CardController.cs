using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Card;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class CardController : ControllerBase
{
    private readonly ICardRepository _cardRepo;
    private readonly ICardDropService _cardDropService;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IEntitlementService _entitlementService;

    public CardController(
        ICardRepository cardRepo,
        ICardDropService cardDropService,
        IChildProfileRepository childProfileRepository,
        IEntitlementService entitlementService)
    {
        _cardRepo = cardRepo;
        _cardDropService = cardDropService;
        _childProfileRepository = childProfileRepository;
        _entitlementService = entitlementService;
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
            IsPremiumExclusive = c.IsPremiumExclusive,
        }).ToList());
    }

    /// <summary>
    /// Çocuğun koleksiyonunu, tüm kartlarla birleştirilmiş şekilde döndürür.
    /// </summary>
    [HttpGet("collection/{childId}")]
    public async Task<IActionResult> GetCollection(Guid childId)
    {
        var userId = GetUserId();
        if (await _childProfileRepository.GetParentUserIdAsync(childId) != userId)
            return Forbid();
        var isPremium = (await _entitlementService.GetForUserAsync(userId)).IsPremium;
        var allCards = await _cardRepo.GetAllActiveAsync();
        var owned = await _cardRepo.GetCollectionByChildAsync(childId);
        var ownedMap = owned.ToDictionary(cc => cc.CardId, cc => cc);
        var economy = await _cardDropService.GetSummaryAsync(childId);

        var dtos = allCards.Select(c =>
        {
            ownedMap.TryGetValue(c.Id, out var ownedCard);
            var isPremiumLocked = c.IsPremiumExclusive && !isPremium;
            return new CollectibleCardDto
            {
                Id = c.Id,
                Name = c.Name,
                Description = c.Description,
                Series = c.Series,
                Rarity = c.Rarity,
                ImageAsset = c.ImageAsset,
                CardNumber = c.CardNumber,
                IsOwned = ownedCard != null && !isPremiumLocked,
                OwnedCount = isPremiumLocked ? 0 : ownedCard?.Count ?? 0,
                FirstEarnedAt = isPremiumLocked ? null : ownedCard?.FirstEarnedAt,
                IsPremiumExclusive = c.IsPremiumExclusive,
                IsPremiumLocked = isPremiumLocked,
            };
        }).ToList();

        return Ok(new CardCollectionDto
        {
            TotalCards = allCards.Count,
            OwnedCount = isPremium
                ? owned.Count
                : owned.Count(x => !x.Card.IsPremiumExclusive),
            Cards = dtos,
            ShardBalance = economy.ShardBalance,
            DailyRemaining = economy.DailyRemaining,
            DailyLimit = economy.DailyLimit,
            PityRemaining = economy.PityRemaining,
            EconomyStage = economy.Stage,
        });
    }

    private Guid GetUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (claim == null || !Guid.TryParse(claim.Value, out var userId))
            throw new UnauthorizedAccessException("Kullanıcı kimliği doğrulanamadı.");
        return userId;
    }

    [HttpGet("economy/{childId}")]
    public async Task<IActionResult> GetEconomy(Guid childId)
    {
        if (await _childProfileRepository.GetParentUserIdAsync(childId) != GetUserId())
            return Forbid();
        return Ok(await _cardDropService.GetSummaryAsync(childId));
    }

    [HttpPost("collection/{childId}/unlock/{cardId}")]
    public async Task<IActionResult> UnlockWithShards(Guid childId, Guid cardId)
    {
        try
        {
            if (await _childProfileRepository.GetParentUserIdAsync(childId) != GetUserId())
                return Forbid();
            return Ok(await _cardDropService.UnlockWithShardsAsync(childId, cardId));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
