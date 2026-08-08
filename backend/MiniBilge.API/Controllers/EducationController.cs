using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Security.Claims;
using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EducationController : ControllerBase
{
    private readonly IEducationService _educationService;
    private readonly ITopicExplanationService _explanationService;
    private readonly IDailyUsageService _dailyUsageService;
    private readonly IEntitlementService _entitlementService;

    public EducationController(
        IEducationService educationService,
        ITopicExplanationService explanationService,
        IDailyUsageService dailyUsageService,
        IEntitlementService entitlementService)
    {
        _educationService = educationService;
        _explanationService = explanationService;
        _dailyUsageService = dailyUsageService;
        _entitlementService = entitlementService;
    }

    /// <summary>
    /// Tüm dersleri getirir (Matematik, İngilizce)
    /// </summary>
    [HttpGet("subjects")]
    public async Task<ActionResult<List<SubjectDto>>> GetSubjects()
    {
        try
        {
            var subjects = await _educationService.GetAllSubjectsAsync();
            return Ok(subjects);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Belirli bir derse ait konuları getirir
    /// </summary>
    [HttpGet("subjects/{subjectId}/topics")]
    public async Task<ActionResult<List<TopicDto>>> GetTopics(Guid subjectId)
    {
        try
        {
            var topics = await _educationService.GetTopicsBySubjectIdAsync(subjectId);
            return Ok(topics);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Belirli bir konuya ait seviyeleri getirir
    /// </summary>
    [HttpGet("topics/{topicId}/levels")]
    public async Task<ActionResult<List<LevelDto>>> GetLevels(Guid topicId)
    {
        try
        {
            var levels = await _educationService.GetLevelsByTopicIdAsync(topicId);
            return Ok(levels);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Belirli bir seviyeden random sorular getirir
    /// </summary>
    [HttpGet("levels/{levelId}/questions")]
    public async Task<ActionResult<List<QuestionDto>>> GetQuestions(
        Guid levelId,
        [FromQuery] Guid childProfileId,
        [FromQuery] int count = 10)
    {
        var consumed = false;
        try
        {
            await _dailyUsageService.ConsumeAsync(
                GetUserId(), childProfileId, "standard_quiz");
            consumed = true;
            var questions = await _educationService.GetQuestionsByLevelIdAsync(levelId, count);
            if (questions.Count == 0)
            {
                await _dailyUsageService.RefundAsync(
                    GetUserId(), childProfileId, "standard_quiz");
            }
            return Ok(questions);
        }
        catch (DailyUsageLimitExceededException ex)
        {
            return StatusCode(StatusCodes.Status429TooManyRequests, ex.Status);
        }
        catch (Exception ex)
        {
            if (consumed)
            {
                await _dailyUsageService.RefundAsync(
                    GetUserId(), childProfileId, "standard_quiz");
            }
            return BadRequest(new { message = ex.Message });
        }
    }

    private Guid GetUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (claim == null || !Guid.TryParse(claim.Value, out var userId))
            throw new UnauthorizedAccessException("Kullanıcı kimliği doğrulanamadı.");
        return userId;
    }

    /// <summary>
    /// Verilen cevabı kontrol eder
    /// </summary>
    [HttpPost("questions/submit-answer")]
    public async Task<ActionResult<SubmitAnswerResponse>> SubmitAnswer([FromBody] SubmitAnswerRequest request)
    {
        try
        {
            var response = await _educationService.SubmitAnswerAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Premium kullanıcılar için yapay zekâ destekli konu anlatımı döndürür.
    /// </summary>
    [HttpPost("explain")]
    public async Task<IActionResult> ExplainTopic([FromBody] ExplainTopicRequest request)
    {
        if (!(await _entitlementService.GetForUserAsync(GetUserId())).IsPremium)
            return StatusCode(StatusCodes.Status403Forbidden, new
            {
                message = "Yapay zekâ destekli konu anlatımı Premium üyelere özeldir."
            });
        if (string.IsNullOrWhiteSpace(request.SubjectName))
            return BadRequest("SubjectName zorunludur.");
        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        var result = await _explanationService.ExplainTopicAsync(request);
        return Ok(result);
    }
}
