using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.DailyPlan;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Authorize]
[Route("api/daily-plan")]
public sealed class DailyPlanController : ControllerBase
{
    private readonly IDailyPlanService _service;

    public DailyPlanController(IDailyPlanService service)
        => _service = service;

    [HttpGet("{childProfileId:guid}/today")]
    public async Task<ActionResult<DailyPlanDto>> GetToday(
        Guid childProfileId,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.GetTodayPlanAsync(
            GetUserId(), childProfileId, cancellationToken));
    }

    [HttpPost("{childProfileId:guid}/items/{itemId:guid}/complete")]
    public async Task<ActionResult<DailyPlanDto>> CompleteItem(
        Guid childProfileId,
        Guid itemId,
        CancellationToken cancellationToken)
    {
        return Ok(await _service.CompleteItemAsync(
            GetUserId(), childProfileId, itemId, cancellationToken));
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
