using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Challenge;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Infrastructure.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ChallengesController : ControllerBase
{
    private readonly IChallengeService _challengeService;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IEntitlementService _entitlementService;

    public ChallengesController(
        IChallengeService challengeService,
        IChildProfileRepository childProfileRepository,
        IEntitlementService entitlementService)
    {
        _challengeService = challengeService;
        _childProfileRepository = childProfileRepository;
        _entitlementService = entitlementService;
    }

    /// <summary>Arkadaşa meydan okuma gönderir.</summary>
    [HttpPost]
    public async Task<IActionResult> Send([FromBody] SendChallengeDto request)
    {
        try
        {
            var dto = await _challengeService.SendChallengeAsync(request, GetUserId());
            return CreatedAtAction(nameof(GetIncoming),
                new { childId = request.ChallengerId }, dto);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            // Yetişkin meydan okuma günlük kotası doldu → mevcut durum DTO'su ile 429.
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
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

    /// <summary>Yetişkin profilinin bugünkü sıralama puanı üretme durumunu döner.</summary>
    [HttpGet("adult-ranked-status")]
    public async Task<ActionResult<AdultRankedStatusDto>> GetAdultRankedStatus(
        [FromQuery] Guid profileId, [FromQuery] Guid? opponentId)
    {
        var dto = await _challengeService.GetAdultRankedStatusAsync(profileId, opponentId);
        return Ok(dto);
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

    /// <summary>Sırası beklenen oyuncuya hatırlatma push bildirimi gönderir.</summary>
    [HttpPost("{id}/remind")]
    public async Task<IActionResult> Remind(Guid id, [FromBody] RemindChallengeDto request)
    {
        try
        {
            var requesterId = request.RequesterId != Guid.Empty
                ? request.RequesterId
                : request.ChallengerId;
            var dto = await _challengeService.RemindChallengeAsync(id, requesterId);
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
            var userId = GetUserId();
            if (await _childProfileRepository.GetParentUserIdAsync(childId) != userId)
                return Forbid();
            var isPremium = (await _entitlementService.GetForUserAsync(userId)).IsPremium;
            var since = DateTime.UtcNow.AddDays(isPremium ? -90 : -7);
            var list = await _challengeService.GetHistoryAsync(childId);
            return Ok(list.Where(x => x.CreatedAt >= since).ToList());
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    private Guid GetUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ??
                    User.FindFirst("sub");
        if (claim == null || !Guid.TryParse(claim.Value, out var userId))
            throw new UnauthorizedAccessException(
                "Kullanıcı kimliği doğrulanamadı.");
        return userId;
    }
}
