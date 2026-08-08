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
public class VocabChallengeController : ControllerBase
{
    private readonly IVocabChallengeService _vocabChallengeService;
    private readonly IDailyUsageService _dailyUsageService;

    public VocabChallengeController(IVocabChallengeService vocabChallengeService, IDailyUsageService dailyUsageService)
    {
        _vocabChallengeService = vocabChallengeService;
        _dailyUsageService = dailyUsageService;
    }

    /// <summary>
    /// Çocuğun öğrendiği flashcard kelimelerinden kişiselleştirilmiş yazma görevi üretir.
    /// </summary>
    [HttpPost("generate")]
    public async Task<IActionResult> Generate([FromBody] GenerateVocabChallengeRequest request)
    {
        if (request.ChildId == Guid.Empty)
            return BadRequest("ChildId zorunludur.");

        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        try
        {
            if (UsesEntitlementV2())
            {
                await _dailyUsageService.ConsumeAiEnglishActivityAsync(
                    GetUserId(), request.ChildId, "ai_vocab_challenge");
            }
            var task = await _vocabChallengeService.GenerateChallengeAsync(request);
            return Ok(task);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
    }

    /// <summary>
    /// Çocuğun yazdığı metni hedef kelime kullanımı dahil değerlendirir.
    /// </summary>
    [HttpPost("evaluate")]
    public async Task<IActionResult> Evaluate([FromBody] EvaluateVocabChallengeRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Text))
            return BadRequest("Text zorunludur.");

        if (string.IsNullOrWhiteSpace(request.TaskText))
            return BadRequest("TaskText zorunludur.");

        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        if (request.TargetWords is null || request.TargetWords.Count == 0)
            return BadRequest("TargetWords zorunludur.");

        var result = await _vocabChallengeService.EvaluateChallengeAsync(request);
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
