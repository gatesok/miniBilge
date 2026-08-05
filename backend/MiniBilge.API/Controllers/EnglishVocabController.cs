using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.DTOs.EnglishVocab;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Enums;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/english-vocab")]
[Authorize]
public class EnglishVocabController : ControllerBase
{
    private const string FunCategoryKey = "english_vocab";

    private readonly IEnglishVocabQuizService _service;
    private readonly IAdaptiveQuizService     _rewardService;
    private readonly IChildProfileRepository  _childProfileRepo;

    public EnglishVocabController(
        IEnglishVocabQuizService service,
        IAdaptiveQuizService     rewardService,
        IChildProfileRepository  childProfileRepo)
    {
        _service          = service;
        _rewardService    = rewardService;
        _childProfileRepo = childProfileRepo;
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
            // Oyuncu kendi profil İngilizce seviyesinin ALTINDA oynuyorsa kart farmlamayı önlemek
            // için kart düşme ihtimalini çok düşük bir geçitle sınırla.
            var dampenCardDrop = await IsBelowProfileLevelAsync(childId, request.EnglishLevel);

            var adaptiveRequest = new AwardAdaptiveQuizRequest
            {
                CorrectCount    = request.CorrectCount,
                TotalCount      = request.TotalCount,
                TopicName       = string.Empty,
                FunCategoryKey  = FunCategoryKey,
                RewardEventId   = request.RewardEventId,
                Difficulty      = request.EnglishLevel,
                DurationSeconds = request.DurationSeconds,
                DampenCardDrop  = dampenCardDrop,
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

    // Oynanan CEFR seviyesi, çocuğun profil seviyesinden düşük mü? (profil yoksa/boşsa: hayır)
    private async Task<bool> IsBelowProfileLevelAsync(Guid childId, string? playedLevel)
    {
        if (!Enum.TryParse<EnglishLevel>(playedLevel?.Trim(), ignoreCase: true, out var played))
            return false;

        var child = await _childProfileRepo.GetByIdAsync(childId);
        if (child?.EnglishLevel is not { } profileLevel) return false;

        return (int)played < (int)profileLevel;
    }
}
