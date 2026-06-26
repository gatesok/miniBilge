using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Pronunciation;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PronunciationController : ControllerBase
{
    private readonly IPronunciationService _pronunciationService;

    public PronunciationController(IPronunciationService pronunciationService)
    {
        _pronunciationService = pronunciationService;
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

        var result = await _pronunciationService.EvaluatePronunciationAsync(request);
        return Ok(result);
    }
}
