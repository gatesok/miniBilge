using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Flashcard;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FlashcardController : ControllerBase
{
    private readonly IFlashcardService _flashcardService;

    public FlashcardController(IFlashcardService flashcardService)
    {
        _flashcardService = flashcardService;
    }

    /// <summary>
    /// Seviyeye göre flashcard deste listesini döndürür.
    /// level: 1=A1, 2=A2, 3=B1, 4=B2, 5=C1, 6=C2
    /// </summary>
    [HttpGet("decks")]
    public async Task<IActionResult> GetDecks([FromQuery] int level, [FromQuery] Guid childId)
    {
        if (level < 1 || level > 6)
            return BadRequest("Geçersiz seviye. 1 (A1) ile 6 (C2) arasında olmalıdır.");

        var decks = await _flashcardService.GetDecksByLevelAsync(level, childId);
        return Ok(decks);
    }

    /// <summary>
    /// Bir destedeki tüm kartları ve çocuğun öğrenme durumunu döndürür.
    /// </summary>
    [HttpGet("decks/{deckId}/cards")]
    public async Task<IActionResult> GetCards(Guid deckId, [FromQuery] Guid childId)
    {
        var cards = await _flashcardService.GetCardsAsync(deckId, childId);
        return Ok(cards);
    }

    /// <summary>
    /// Bir podcast episode'una bağlı flashcard destesini döndürür.
    /// </summary>
    [HttpGet("episode/{episodeId}")]
    public async Task<IActionResult> GetDeckByEpisode(Guid episodeId, [FromQuery] Guid childId)
    {
        var deck = await _flashcardService.GetDeckByEpisodeAsync(episodeId, childId);
        if (deck is null)
            return NotFound("Bu bölüme ait flashcard destesi bulunamadı.");

        return Ok(deck);
    }

    /// <summary>
    /// Bir kartı "Biliyorum" veya "Bilmiyorum" olarak işaretler.
    /// </summary>
    [HttpPost("cards/{flashcardId}/mark")]
    public async Task<IActionResult> MarkCard(Guid flashcardId, [FromBody] MarkFlashcardRequest request)
    {
        await _flashcardService.MarkCardAsync(request.ChildProfileId, flashcardId, request.IsLearned);
        return Ok();
    }

    /// <summary>
    /// Çalışma oturumunu tamamlar. İlk %100 tamamlamada coin ödülü verir.
    /// </summary>
    [HttpPost("decks/{deckId}/complete")]
    public async Task<IActionResult> CompleteSession(Guid deckId, [FromQuery] Guid childId)
    {
        var result = await _flashcardService.CompleteSessionAsync(childId, deckId);
        return Ok(result);
    }
}
