using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using MiniBilge.Application.DTOs.RolePlay;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class RolePlayController : ControllerBase
{
    private readonly IRolePlayService _rolePlayService;
    private readonly IDailyUsageService _dailyUsageService;

    public RolePlayController(IRolePlayService rolePlayService, IDailyUsageService dailyUsageService)
    {
        _rolePlayService = rolePlayService;
        _dailyUsageService = dailyUsageService;
    }

    /// <summary>
    /// Belirtilen seviyedeki senaryoları listeler.
    /// </summary>
    [HttpGet("scenarios")]
    public async Task<IActionResult> GetScenarios([FromQuery] string level)
    {
        if (string.IsNullOrWhiteSpace(level))
            return BadRequest("level zorunludur.");

        var scenarios = await _rolePlayService.GetScenariosAsync(level);
        return Ok(scenarios);
    }

    /// <summary>
    /// Yeni bir rol yapma oturumu başlatır ve yapay zekanın ilk mesajını döner.
    /// </summary>
    [HttpPost("start")]
    public async Task<IActionResult> Start([FromBody] StartRolePlayRequest request)
    {
        if (request.ChildProfileId == Guid.Empty)
            return BadRequest("ChildProfileId zorunludur.");

        if (string.IsNullOrWhiteSpace(request.ScenarioKey))
            return BadRequest("ScenarioKey zorunludur.");

        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        try
        {
            if (UsesEntitlementV2())
            {
                await _dailyUsageService.ConsumeAiEnglishActivityAsync(
                    GetUserId(), request.ChildProfileId, "ai_roleplay");
            }
            var result = await _rolePlayService.StartSessionAsync(request);
            return Ok(result);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
    }

    /// <summary>
    /// Kullanıcı mesajını gönderir ve yapay zekanın yanıtını alır.
    /// </summary>
    [HttpPost("turn")]
    public async Task<IActionResult> Turn([FromBody] SendTurnRequest request)
    {
        if (request.SessionId == Guid.Empty)
            return BadRequest("SessionId zorunludur.");

        if (string.IsNullOrWhiteSpace(request.UserMessage))
            return BadRequest("UserMessage zorunludur.");

        var result = await _rolePlayService.SendTurnAsync(request);
        return Ok(result);
    }

    /// <summary>
    /// Oturumu tamamlar, nihai değerlendirme ve ödülleri döner.
    /// </summary>
    [HttpPost("end")]
    public async Task<IActionResult> End([FromBody] EndSessionRequest request)
    {
        if (request.SessionId == Guid.Empty)
            return BadRequest("SessionId zorunludur.");

        var result = await _rolePlayService.EndSessionAsync(request);
        return Ok(result);
    }

    private Guid GetUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (claim == null || !Guid.TryParse(claim.Value, out var userId))
            throw new UnauthorizedAccessException("Kullanıcı kimliği doğrulanamadı.");
        return userId;
    }

    private bool UsesEntitlementV2() =>
        Request.Headers["X-MiniBilge-Entitlements"] == "2";
}
