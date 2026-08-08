using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using MiniBilge.Application.DTOs.Pronunciation;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PronunciationController : ControllerBase
{
    private readonly IPronunciationService _pronunciationService;
    private readonly IDailyUsageService _dailyUsageService;

    public PronunciationController(IPronunciationService pronunciationService, IDailyUsageService dailyUsageService)
    {
        _pronunciationService = pronunciationService;
        _dailyUsageService = dailyUsageService;
    }

    /// <summary>
    /// Verilen CEFR seviyesi için telaffuz pratiğine uygun cümleler döndürür.
    /// Flashcard örnek cümleleri kullanılır; yoksa fallback cümle seti devreye girer.
    /// </summary>
    [HttpGet("sentences")]
    public async Task<IActionResult> GetSentences([FromQuery] int level = 1, [FromQuery] int count = 10)
    {
        var sentences = await _pronunciationService.GetSentencesAsync(level, count);
        return Ok(sentences);
    }

    /// <summary>
    /// Hedef cümle ile speech_to_text çıktısını karşılaştırır.
    /// Her kelime için isCorrect + hint döner, genel skor 0-100 arası.
    /// </summary>
    [HttpPost("evaluate")]
    public async Task<IActionResult> Evaluate([FromBody] EvaluatePronunciationRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.TargetSentence))
            return BadRequest("TargetSentence zorunludur.");

        if (string.IsNullOrWhiteSpace(request.SpokenText))
            return BadRequest("SpokenText zorunludur.");

        try
        {
            if (UsesEntitlementV2() && request.ChildProfileId.HasValue)
            {
                await _dailyUsageService.ConsumeAiEnglishActivityAsync(
                    GetUserId(), request.ChildProfileId.Value, "ai_pronunciation");
            }
            var result = await _pronunciationService.EvaluatePronunciationAsync(request);
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
