using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.DTOs.EnglishVocab;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/english-vocab")]
[Authorize]
public class EnglishVocabController : ControllerBase
{
    private const string FunCategoryKey = "english_vocab";

    private readonly IEnglishVocabQuizService _service;
    private readonly IAdaptiveQuizService     _rewardService;

    public EnglishVocabController(
        IEnglishVocabQuizService service,
        IAdaptiveQuizService     rewardService)
    {
        _service       = service;
        _rewardService = rewardService;
    }

    /// <summary>Seçili CEFR seviyesinde dinamik çeldiricili kelime soruları üretir.</summary>
    [HttpPost("generate")]
    public async Task<ActionResult<List<VocabQuestionDto>>> Generate(
        [FromBody] GenerateVocabQuizRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.EnglishLevel))
            return BadRequest(new { message = "EnglishLevel boş olamaz." });

        if (request.Count is < 1 or > 20)
            return BadRequest(new { message = "Count 1-20 arasında olmalıdır." });

        try
        {
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

    /// <summary>Quiz tamamlama ödülü (yıldız/kart/rozet) + aktivite ve streak kaydı.</summary>
    [HttpPost("{childId}/award")]
    public async Task<ActionResult<AdaptiveQuizRewardDto>> Award(
        Guid childId, [FromBody] AwardVocabQuizRequest request)
    {
        try
        {
            var adaptiveRequest = new AwardAdaptiveQuizRequest
            {
                CorrectCount    = request.CorrectCount,
                TotalCount      = request.TotalCount,
                TopicName       = string.Empty,
                FunCategoryKey  = FunCategoryKey,
                RewardEventId   = request.RewardEventId,
                Difficulty      = request.EnglishLevel,
                DurationSeconds = request.DurationSeconds,
            };

            var reward = await _rewardService.AwardAsync(childId, adaptiveRequest);
            await _service.RecordCompletionAsync(childId, request);
            return Ok(reward);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }
}
