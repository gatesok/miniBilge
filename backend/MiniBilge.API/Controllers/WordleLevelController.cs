using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.WordleLevel;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/wordle-levels")]
[Authorize]
public class WordleLevelController : ControllerBase
{
    private readonly IWordleLevelService _service;

    public WordleLevelController(IWordleLevelService service)
        => _service = service;

    /// <summary>Mevcut seviyeyi ve durum döner.</summary>
    [HttpGet("{childId}/current")]
    public async Task<ActionResult<WordleLevelStateDto>> GetCurrent(Guid childId)
    {
        try { return Ok(await _service.GetCurrentLevelAsync(childId)); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Mevcut seviye için AI'dan kelime üretir.</summary>
    [HttpPost("{childId}/generate")]
    public async Task<ActionResult<WordleLevelStateDto>> Generate(Guid childId)
    {
        try { return Ok(await _service.GenerateWordAsync(childId)); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Tahmin gönderir.</summary>
    [HttpPost("{childId}/guess")]
    public async Task<ActionResult<WordleLevelSubmitResponse>> SubmitGuess(
        Guid childId, [FromBody] WordleLevelSubmitRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Guess))
            return BadRequest(new { message = "Tahmin boş olamaz." });

        try { return Ok(await _service.SubmitGuessAsync(childId, request)); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Seviyeyi sıfırlar: eski tahminler silinir, yeni kelime gelir. Seviye değişmez.</summary>
    [HttpPost("{childId}/retry")]
    public async Task<ActionResult<WordleLevelStateDto>> Retry(Guid childId)
    {
        try { return Ok(await _service.RetryLevelAsync(childId)); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Seviyeyi pas geçer (skip ticket harcar).</summary>
    [HttpPost("{childId}/skip")]
    public async Task<ActionResult<WordleLevelStateDto>> Skip(Guid childId)
    {
        try { return Ok(await _service.SkipLevelAsync(childId)); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Kullanıcı istatistiklerini döner.</summary>
    [HttpGet("{childId}/stats")]
    public async Task<ActionResult<WordleLevelStatsDto>> GetStats(Guid childId)
    {
        try { return Ok(await _service.GetStatsAsync(childId)); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Joker hakkı kullanır — rastgele bir harfi açar.</summary>
    [HttpPost("{childId}/joker")]
    public async Task<ActionResult<JokerResponse>> UseJoker(Guid childId)
    {
        try { return Ok(await _service.UseJokerAsync(childId)); }
        catch (InvalidOperationException ex) { return BadRequest(new { message = ex.Message }); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }

    /// <summary>Reklam ödülü: +1 joker bileti kazanır (kullanmaz).</summary>
    [HttpPost("{childId}/earn-joker")]
    public async Task<ActionResult<EarnJokerResponse>> EarnJoker(Guid childId)
    {
        try { return Ok(await _service.EarnJokerAsync(childId)); }
        catch (Exception ex) { return StatusCode(500, new { message = ex.Message }); }
    }
}
