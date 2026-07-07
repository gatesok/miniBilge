using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Wordle;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Data;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/wordle")]
[Authorize]
public class WordleController : ControllerBase
{
    private readonly IWordleService         _wordle;
    private readonly ApplicationDbContext   _db;

    public WordleController(IWordleService wordle, ApplicationDbContext db)
    {
        _wordle = wordle;
        _db     = db;
    }

    /// <summary>Bugünkü oyun durumunu döner. Henüz başlanmamışsa yeni oyun başlatır.</summary>
    [HttpGet("{childProfileId}/today")]
    public async Task<ActionResult<WordleTodayDto>> GetToday(
        Guid childProfileId, [FromQuery] string language = "tr")
    {
        try
        {
            var dto = await _wordle.GetTodayAsync(childProfileId, language);
            return Ok(dto);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Tahmin gönderir. Yanıtta pattern + solved + attemptsLeft döner.</summary>
    [HttpPost("{childProfileId}/guess")]
    public async Task<ActionResult<SubmitGuessResponse>> SubmitGuess(
        Guid childProfileId,
        [FromQuery] string language,
        [FromBody]  SubmitGuessRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Guess))
            return BadRequest(new { message = "Tahmin boş olamaz." });

        try
        {
            var response = await _wordle.SubmitGuessAsync(childProfileId, language, request);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Kullanıcının Wordle istatistiklerini döner.</summary>
    [HttpGet("{childProfileId}/stats")]
    public async Task<ActionResult<WordleStatsDto>> GetStats(
        Guid childProfileId, [FromQuery] string language = "tr")
    {
        try
        {
            var stats = await _wordle.GetStatsAsync(childProfileId, language);
            return Ok(stats);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }
}
