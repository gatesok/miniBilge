using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Writing;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class VocabChallengeController : ControllerBase
{
    private readonly IVocabChallengeService _vocabChallengeService;

    public VocabChallengeController(IVocabChallengeService vocabChallengeService)
    {
        _vocabChallengeService = vocabChallengeService;
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

        var task = await _vocabChallengeService.GenerateChallengeAsync(request);
        return Ok(task);
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
}
