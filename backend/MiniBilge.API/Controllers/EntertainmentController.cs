using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.AdaptiveQuiz;
using MiniBilge.Application.DTOs.Entertainment;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/entertainment")]
[Authorize]
public class EntertainmentController : ControllerBase
{
    private readonly IEntertainmentQuizService _service;
    private readonly IAdaptiveQuizService      _rewardService;
    private readonly IFactOrFictionService     _ffService;
    private readonly IKimBuService             _kimBuService;
    private readonly INeOrtakService            _neOrtakService;
    private readonly IDailyUsageService         _usageService;
    private readonly IProgressRepository        _progressRepository;

    public EntertainmentController(
        IEntertainmentQuizService service,
        IAdaptiveQuizService      rewardService,
        IFactOrFictionService     ffService,
        IKimBuService             kimBuService,
        INeOrtakService           neOrtakService,
        IDailyUsageService        usageService,
        IProgressRepository       progressRepository)
    {
        _service        = service;
        _rewardService  = rewardService;
        _ffService      = ffService;
        _kimBuService   = kimBuService;
        _neOrtakService = neOrtakService;
        _usageService   = usageService;
        _progressRepository = progressRepository;
    }

    /// <summary>Tüm eğlence topic listesini döner.</summary>
    [HttpGet("topics")]
    public IActionResult GetTopics()
        => Ok(_service.GetTopics());

    /// <summary>Belirtilen topic ve zorlukta GPT ile soru üretir.</summary>
    [HttpPost("generate")]
    public async Task<ActionResult<List<EntertainmentQuestionDto>>> Generate(
        [FromQuery] Guid? childId,
        [FromBody] GenerateEntertainmentRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.TopicKey))
            return BadRequest(new { message = "TopicKey boş olamaz." });

        if (request.Count is < 1 or > 10)
            return BadRequest(new { message = "Count 1-10 arasında olmalıdır." });

        try
        {
            await ConsumeUsageIfSupportedAsync(childId);
            request.DateSeed ??= DateTime.UtcNow.ToString("d MMMM yyyy");
            var questions = await _service.GenerateAsync(request);
            return Ok(questions);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
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

    /// <summary>Quiz tamamlama ödülü — aynı tier mantığı (kart, yıldız, rozet).</summary>
    [HttpPost("{childId}/award")]
    public async Task<ActionResult<AdaptiveQuizRewardDto>> Award(
        Guid childId, [FromBody] AwardAdaptiveQuizRequest request)
    {
        // TopicName mastery tracking için kullanılır; entertainment'ta gerek yok
        request.TopicName = string.Empty;
        try
        {
            var reward = await _rewardService.AwardAsync(childId, request);
            await RecordEntertainmentActivityAsync(childId, request);
            return Ok(reward);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    /// <summary>
    /// Eğlence quizi tamamlamasını haftalık çalışma süresi/soru sayısı için kaydeder.
    /// Bu quizler AnswerAttempt üretmediğinden rapor/hedef hesaplamalarına ayrı tabloyla girer.
    /// </summary>
    private async Task RecordEntertainmentActivityAsync(Guid childId, AwardAdaptiveQuizRequest request)
    {
        try
        {
            // İstemci süresini makul aralığa sıkıştır (kötüye kullanım/hatalı ölçüm koruması).
            var durationSeconds = Math.Clamp(request.DurationSeconds ?? 0, 0, 3600);
            var now = DateTime.UtcNow;
            await _progressRepository.AddEntertainmentActivityIfNewAsync(new EntertainmentActivity
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childId,
                CategoryKey = string.IsNullOrWhiteSpace(request.FunCategoryKey) ? null : request.FunCategoryKey.Trim(),
                QuestionCount = Math.Max(0, request.TotalCount),
                CorrectCount = Math.Max(0, request.CorrectCount),
                DurationSeconds = durationSeconds,
                CompletedAt = now,
                IdempotencyKey = request.RewardEventId,
                CreatedAt = now,
            });
        }
        catch
        {
            // Aktivite kaydı ödülü bloklamamalı; sessizce geç.
        }
    }

    // ── Gerçek mi Uydurma mı? ────────────────────────────────────────────────

    /// <summary>Belirtilen zorlukta 10 adet Gerçek mi Uydurma mı? ifadesi üretir.</summary>
    [HttpPost("fact-or-fiction/generate")]
    public async Task<ActionResult<List<FactOrFictionQuestionDto>>> GenerateFactOrFiction(
        [FromQuery] Guid? childId,
        [FromBody] GenerateFactOrFictionRequest request)
    {
        try
        {
            await ConsumeUsageIfSupportedAsync(childId);
            request.DateSeed ??= DateTime.UtcNow.ToString("d MMMM yyyy");
            var items = await _ffService.GenerateAsync(request);
            return Ok(items);
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

    // ── Kim Bu? ───────────────────────────────────────────────────────────────

    /// <summary>Belirtilen zorlukta 5 konuluk bir Kim Bu? turu üretir.</summary>
    [HttpPost("kim-bu/generate")]
    public async Task<ActionResult<KimBuRoundDto>> GenerateKimBu(
        [FromQuery] Guid? childId,
        [FromBody] GenerateKimBuRequest request)
    {
        try
        {
            await ConsumeUsageIfSupportedAsync(childId);
            request.DateSeed ??= DateTime.UtcNow.ToString("d MMMM yyyy");
            var round = await _kimBuService.GenerateAsync(request);
            return Ok(round);
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

    // ── Ne Ortak? ─────────────────────────────────────────────────────────────────

    /// <summary>Belirtilen zorlukta 10 adet Ne Ortak? sorusu üretir.</summary>
    [HttpPost("ne-ortak/generate")]
    public async Task<ActionResult<List<NeOrtakQuestionDto>>> GenerateNeOrtak(
        [FromQuery] Guid? childId,
        [FromBody] GenerateNeOrtakRequest request)
    {
        try
        {
            await ConsumeUsageIfSupportedAsync(childId);
            request.DateSeed ??= DateTime.UtcNow.ToString("d MMMM yyyy");
            var questions = await _neOrtakService.GenerateAsync(request);
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

    private Task ConsumeUsageIfSupportedAsync(Guid? childId)
        => childId.HasValue && childId.Value != Guid.Empty
            ? _usageService.ConsumeAsync(
                GetUserId(), childId.Value, "entertainment")
            : Task.CompletedTask;

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
