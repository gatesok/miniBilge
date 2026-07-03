using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/adaptive-quiz")]
[Authorize]
public class AdaptiveQuizController : ControllerBase
{
    private readonly IAdaptiveQuizService _service;

    public AdaptiveQuizController(IAdaptiveQuizService service)
        => _service = service;

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
        Guid childId, [FromBody] GenerateAdaptiveQuestionsRequest request)
    {
        try
        {
            var questions = await _service.GenerateQuestionsAsync(childId, request);
            return Ok(questions);
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
}
