using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/entertainment")]
[Authorize]
public class EntertainmentController : ControllerBase
{
    private readonly IEntertainmentQuizService _service;

    public EntertainmentController(IEntertainmentQuizService service)
        => _service = service;

    /// <summary>Tüm eğlence topic listesini döner.</summary>
    [HttpGet("topics")]
    public IActionResult GetTopics()
        => Ok(_service.GetTopics());

    /// <summary>Belirtilen topic ve zorlukta GPT ile soru üretir.</summary>
    [HttpPost("generate")]
    public async Task<ActionResult<List<EntertainmentQuestionDto>>> Generate(
        [FromBody] GenerateEntertainmentRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.TopicKey))
            return BadRequest(new { message = "TopicKey boş olamaz." });

        if (request.Count is < 1 or > 10)
            return BadRequest(new { message = "Count 1-10 arasında olmalıdır." });

        try
        {
            // Tarih seed gönderilmemişse bugünkü tarihi ekle
            request.DateSeed ??= DateTime.UtcNow.ToString("d MMMM yyyy");

            var questions = await _service.GenerateAsync(request);
            return Ok(questions);
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
}
