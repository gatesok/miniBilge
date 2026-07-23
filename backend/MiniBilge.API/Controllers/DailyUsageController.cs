using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Usage;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Authorize]
[Route("api/usage")]
public sealed class DailyUsageController : ControllerBase
{
    private readonly IDailyUsageService _service;

    public DailyUsageController(IDailyUsageService service)
        => _service = service;

    [HttpGet("{childProfileId:guid}/{featureKey}")]
    public async Task<ActionResult<DailyUsageStatusDto>> GetStatus(
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.GetStatusAsync(
            GetUserId(), childProfileId, featureKey, cancellationToken));
    }

    [HttpPost("{childProfileId:guid}/{featureKey}/consume")]
    public async Task<ActionResult<DailyUsageStatusDto>> Consume(
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken)
    {
        try
        {
            return Ok(await _service.ConsumeAsync(
                GetUserId(), childProfileId, featureKey, cancellationToken));
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
    }

    [HttpPost("{childProfileId:guid}/{featureKey}/rewarded-bonus")]
    public async Task<ActionResult<DailyUsageStatusDto>> GrantRewardedBonus(
        Guid childProfileId,
        string featureKey,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.GrantRewardedBonusAsync(
            GetUserId(), childProfileId, featureKey, cancellationToken));
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
