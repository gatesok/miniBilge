using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Progress;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Parent")]
public class ProgressController : ControllerBase
{
    private readonly IProgressService _progressService;
    private readonly IBadgeService _badgeService;

    public ProgressController(IProgressService progressService, IBadgeService badgeService)
    {
        _progressService = progressService;
        _badgeService = badgeService;
    }

    /// <summary>
    /// Çocuğun bölüm sonuç ilerlemesini kaydeder
    /// </summary>
    /// <param name="request">Bölüm sonuç bilgileri</param>
    [HttpPost]
    public async Task<ActionResult> SaveProgress([FromBody] SaveProgressRequest request)
    {
        try
        {
            // Puan ve yıldız hesapla
            var calculatedScore = _progressService.CalculateScore(
                request.CorrectCount, 
                request.TotalQuestions
            );
            
            var calculatedStars = _progressService.CalculateStars(request.SuccessPercentage);

            // Request'e hesaplanan değerleri set et
            request.Score = calculatedScore;
            request.Stars = calculatedStars;

            await _progressService.SaveProgressAsync(request);

            // Rozet kontrolü — QuizCompleted trigger
            var badgeCtx = new BadgeTriggerContext
            {
                SuccessPercentage = (double)request.SuccessPercentage,
                SubjectName = request.SubjectName,
                EnglishLevel = request.EnglishLevel,
                QuizDurationSeconds = request.QuizDurationSeconds,
            };
            var earnedBadges = await _badgeService.CheckAndAwardAsync(
                request.ChildId,
                BadgeTrigger.QuizCompleted,
                badgeCtx);

            return Ok(new 
            { 
                message = "Progress kaydedildi",
                score = calculatedScore,
                stars = calculatedStars,
                earnedBadges,
            });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun genel ilerlemesini getirir
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    [HttpGet("{childId}")]
    public async Task<ActionResult<ChildProgressDto>> GetProgress(Guid childId)
    {
        try
        {
            var progress = await _progressService.GetProgressAsync(childId);
            return Ok(progress);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun tüm bölüm sonuçlarını getirir
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    [HttpGet("{childId}/level-results")]
    public async Task<ActionResult<List<LevelResultDto>>> GetLevelResults(Guid childId)
    {
        try
        {
            var results = await _progressService.GetLevelResultsAsync(childId);
            return Ok(results);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Soru çözüm denemesini kaydeder
    /// </summary>
    /// <param name="request">Cevap denemesi bilgileri</param>
    [HttpPost("attempt")]
    public async Task<ActionResult> SaveAnswerAttempt([FromBody] SaveAnswerAttemptRequest request)
    {
        try
        {
            await _progressService.SaveAnswerAttemptAsync(request);
            return Ok(new { message = "Answer attempt kaydedildi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Level'ın unlock olup olmadığını kontrol eder
    /// </summary>
    /// <param name="childId">Çocuk ID</param>
    /// <param name="levelId">Level ID</param>
    [HttpGet("{childId}/check-unlock/{levelId}")]
    public async Task<ActionResult<bool>> CheckLevelUnlock(Guid childId, Guid levelId)
    {
        try
        {
            var isUnlocked = await _progressService.CheckLevelUnlockAsync(childId, levelId);
            return Ok(new { isUnlocked });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
