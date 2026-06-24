using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Writing;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WritingController : ControllerBase
{
    private readonly IWritingService _writingService;

    public WritingController(IWritingService writingService)
    {
        _writingService = writingService;
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

        var result = await _writingService.EvaluateWritingAsync(request);
        return Ok(result);
    }
}
