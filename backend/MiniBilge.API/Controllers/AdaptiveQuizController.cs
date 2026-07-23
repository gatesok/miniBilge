using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/adaptive-quiz")]
[Authorize]
public class AdaptiveQuizController : ControllerBase
{
    private readonly IAdaptiveQuizService _service;
    private readonly IDailyUsageService _usageService;

    public AdaptiveQuizController(
        IAdaptiveQuizService service,
        IDailyUsageService usageService)
    {
        _service = service;
        _usageService = usageService;
    }

    /// <summary>Çocuğun son 30 günlük performansına göre zayıf konuları döner.</summary>
    [HttpGet("{childId}/weak-topics")]
    public async Task<ActionResult<List<WeakTopicDto>>> GetWeakTopics(Guid childId)
    {
        try
        {
            var topics = await _service.GetWeakTopicsAsync(childId);
            return Ok(topics);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Belirtilen konu için GPT-4o-mini ile sorular üretir.</summary>
    [HttpPost("{childId}/generate")]
    public async Task<ActionResult<List<AdaptiveQuestionDto>>> Generate(
        Guid childId,
        [FromQuery] bool enforceUsage,
        [FromBody] GenerateAdaptiveQuestionsRequest request)
    {
        try
        {
            if (enforceUsage)
            {
                await _usageService.ConsumeAsync(
                    GetUserId(), childId, "adaptive_quiz");
            }
            var questions = await _service.GenerateQuestionsAsync(childId, request);
            return Ok(questions);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Çocuğun verdiği cevabı kaydeder.</summary>
    [HttpPost("{childId}/submit")]
    public async Task<IActionResult> Submit(
        Guid childId, [FromBody] SubmitAdaptiveAnswerRequest request)
    {
        try
        {
            await _service.SubmitAnswerAsync(childId, request);
            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>Quiz bitince yıldız/coin/kart/rozet ödüllerini verir.</summary>
    [HttpPost("{childId}/award")]
    public async Task<ActionResult<AdaptiveQuizRewardDto>> Award(
        Guid childId, [FromBody] AwardAdaptiveQuizRequest request)
    {
        try
        {
            var reward = await _service.AwardAsync(childId, request);
            return Ok(reward);
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
