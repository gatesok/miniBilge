using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Progress;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Data;
namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Parent")]
public class ProgressController : ControllerBase
{
    private readonly IProgressService _progressService;
    private readonly IBadgeService _badgeService;
    private readonly ICardDropService _cardDropService;
    private readonly ApplicationDbContext _db;

    public ProgressController(
        IProgressService progressService,
        IBadgeService badgeService,
        ICardDropService cardDropService,
        ApplicationDbContext db)
    {
        _progressService = progressService;
        _badgeService = badgeService;
        _cardDropService = cardDropService;
        _db = db;
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

            request.Score = calculatedScore;
            request.Stars = calculatedStars;

            await _progressService.SaveProgressAsync(request);

            // ── Rozet context hazırlığı ──────────────────────────────────────
            // Level → Topic → GradeLevel bilgisini çek
            var levelGrade = await _db.Set<MiniBilge.Domain.Entities.Level>()
                .Where(l => l.Id == request.LevelId)
                .Select(l => new { l.TopicId, Topic = new { l.Topic.GradeLevel, l.Topic.Name, l.Topic.SubjectId } })
                .FirstOrDefaultAsync();

            // Child'ın sınıf seviyesi
            var childGrade = await _db.Set<MiniBilge.Domain.Entities.ChildProfile>()
                .Where(c => c.Id == request.ChildId)
                .Select(c => c.GradeLevel)
                .FirstOrDefaultAsync();

            // Bu level daha önce ≥7 doğru ile geçilmiş mi? (şu anki kayıt hariç)
            var previousPass = await _db.Set<MiniBilge.Domain.Entities.LevelResult>()
                .Where(lr => lr.ChildId == request.ChildId
                          && lr.LevelId == request.LevelId
                          && lr.CorrectCount >= 7
                          && lr.CreatedAt < DateTime.UtcNow.AddSeconds(-5)) // az önce kaydettiğimizi hariç tut
                .AnyAsync();

            // Kural: ≥7 doğru VE level grade'i child grade'inden küçük değil VE daha önce geçilmemiş
            int levelGradeInt = levelGrade?.Topic.GradeLevel.HasValue == true
                ? (int)levelGrade.Topic.GradeLevel!.Value : 0;
            int childGradeInt = (int)childGrade;

            bool isEligibleForFirstQuiz = request.CorrectCount >= 7
                && levelGradeInt >= childGradeInt
                && !previousPass;

            var badgeCtx = new BadgeTriggerContext
            {
                SuccessPercentage = (double)request.SuccessPercentage,
                SubjectName = request.SubjectName,
                EnglishLevel = request.EnglishLevel,
                QuizDurationSeconds = request.QuizDurationSeconds,
                IsEligibleNewQuiz = isEligibleForFirstQuiz,
            };

            var earnedBadges = await _badgeService.CheckAndAwardAsync(
                request.ChildId,
                BadgeTrigger.QuizCompleted,
                badgeCtx);

            // ── Kart drop ───────────────────────────────────────────────────
            // Her quiz tamamlanınca %60 common / %25 rare / %12 epic / %3 legendary
            var cardDrop = await _cardDropService.TryDropAsync(
                request.ChildId, "quiz_complete");

            return Ok(new 
            { 
                message = "Progress kaydedildi",
                score = calculatedScore,
                stars = calculatedStars,
                earnedBadges,
                cardDrop,
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
