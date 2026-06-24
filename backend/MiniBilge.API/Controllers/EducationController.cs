using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Education;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EducationController : ControllerBase
{
    private readonly IEducationService _educationService;
    private readonly ITopicExplanationService _explanationService;

    public EducationController(
        IEducationService educationService,
        ITopicExplanationService explanationService)
    {
        _educationService = educationService;
        _explanationService = explanationService;
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
    public async Task<ActionResult<List<QuestionDto>>> GetQuestions(Guid levelId, [FromQuery] int count = 10)
    {
        try
        {
            var questions = await _educationService.GetQuestionsByLevelIdAsync(levelId, count);
            return Ok(questions);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
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
    /// Rewarded reklam izlendikten sonra çağrılır.
    /// GPT-4o-mini destekli konu anlatımı döndürür.
    /// </summary>
    [HttpPost("explain")]
    public async Task<IActionResult> ExplainTopic([FromBody] ExplainTopicRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.SubjectName))
            return BadRequest("SubjectName zorunludur.");
        if (string.IsNullOrWhiteSpace(request.Level))
            return BadRequest("Level zorunludur.");

        var result = await _explanationService.ExplainTopicAsync(request);
        return Ok(result);
    }
}
