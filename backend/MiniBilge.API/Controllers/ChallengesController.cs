using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Challenge;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChallengesController : ControllerBase
{
    private readonly IChallengeService _challengeService;

    public ChallengesController(IChallengeService challengeService)
    {
        _challengeService = challengeService;
    }

    /// <summary>Arkadaşa meydan okuma gönderir.</summary>
    [HttpPost]
    public async Task<IActionResult> Send([FromBody] SendChallengeDto request)
    {
        try
        {
            var dto = await _challengeService.SendChallengeAsync(
                request.ChallengerId, request.ChallengeeId, request.LevelId);
            return CreatedAtAction(nameof(GetIncoming),
                new { childId = request.ChallengerId }, dto);
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

    /// <summary>Meydan okumayı kabul eder.</summary>
    [HttpPost("{id}/accept")]
    public async Task<IActionResult> Accept(Guid id, [FromBody] RespondChallengeDto request)
    {
        try
        {
            var dto = await _challengeService.AcceptChallengeAsync(id, request.ChallengeeId);
            return Ok(dto);
        }
        catch (KeyNotFoundException)      { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Meydan okumayı reddeder.</summary>
    [HttpPost("{id}/decline")]
    public async Task<IActionResult> Decline(Guid id, [FromBody] RespondChallengeDto request)
    {
        try
        {
            var dto = await _challengeService.DeclineChallengeAsync(id, request.ChallengeeId);
            return Ok(dto);
        }
        catch (KeyNotFoundException)        { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Skor gönderir; her iki taraf oynadıysa Completed yapar.</summary>
    [HttpPost("{id}/submit-score")]
    public async Task<IActionResult> SubmitScore(Guid id, [FromBody] SubmitChallengeScoreDto request)
    {
        try
        {
            var dto = await _challengeService.SubmitScoreAsync(id, request.ChildId, request.Score);
            return Ok(dto);
        }
        catch (KeyNotFoundException)        { return NotFound(); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>childId'ye gelen aktif meydan okumaları listeler.</summary>
    [HttpGet("incoming")]
    public async Task<IActionResult> GetIncoming([FromQuery] Guid childId)
    {
        try
        {
            var list = await _challengeService.GetIncomingAsync(childId);
            return Ok(list);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>childId'nin gönderdiği aktif meydan okumaları listeler.</summary>
    [HttpGet("outgoing")]
    public async Task<IActionResult> GetOutgoing([FromQuery] Guid childId)
    {
        try
        {
            var list = await _challengeService.GetOutgoingAsync(childId);
            return Ok(list);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>childId'nin geçmiş (tamamlanan/süresi dolan) meydan okumalarını listeler.</summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetHistory([FromQuery] Guid childId)
    {
        try
        {
            var list = await _challengeService.GetHistoryAsync(childId);
            return Ok(list);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }
}
