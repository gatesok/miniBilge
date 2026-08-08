using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using MiniBilge.Application.DTOs.Writing;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WritingController : ControllerBase
{
    private readonly IWritingService _writingService;
    private readonly IDailyUsageService _dailyUsageService;

    public WritingController(IWritingService writingService, IDailyUsageService dailyUsageService)
    {
        _writingService = writingService;
        _dailyUsageService = dailyUsageService;
    }

    /// <summary>
    /// Verilen CEFR seviyesi için GPT tarafından üretilmiş 3 yazma promptu döndürür.
    /// </summary>
    [HttpPost("prompts")]
    public async Task<IActionResult> GetPrompts([FromBody] GeneratePromptsRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        var prompts = await _writingService.GeneratePromptsAsync(request);
        return Ok(prompts);
    }

    /// <summary>
    /// Kullanıcının yazdığı metni GPT-4o-mini ile değerlendirir.
    /// Çocuk profili varsa coin/yıldız ödülü de eklenir.
    /// </summary>
    [HttpPost("evaluate")]
    public async Task<IActionResult> Evaluate([FromBody] EvaluateWritingRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Text))
            return BadRequest("Text zorunludur.");

        if (string.IsNullOrWhiteSpace(request.PromptText))
            return BadRequest("PromptText zorunludur.");

        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        try
        {
            if (UsesEntitlementV2() && request.ChildProfileId.HasValue)
            {
                await _dailyUsageService.ConsumeAiEnglishActivityAsync(
                    GetUserId(), request.ChildProfileId.Value, "ai_writing");
            }
            var result = await _writingService.EvaluateWritingAsync(request);
            return Ok(result);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
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
