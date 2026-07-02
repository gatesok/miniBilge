using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/parent-report")]
[Authorize(Roles = "Parent")]
public class ParentReportController : ControllerBase
{
    private readonly IParentReportingService _reportingService;
    private readonly IChildProfileService _childProfileService;

    public ParentReportController(
        IParentReportingService reportingService,
        IChildProfileService childProfileService)
    {
        _reportingService = reportingService;
        _childProfileService = childProfileService;
    }

    /// <summary>
    /// Çocuğun belirtilen güne ait günlük özetini getirir
    /// </summary>
    /// <param name="childId">Çocuk profil ID</param>
    /// <param name="date">Tarih (yyyy-MM-dd). Belirtilmezse bugün kullanılır.</param>
    [HttpGet("{childId}/daily")]
    public async Task<ActionResult<DailySummaryDto>> GetDailySummary(Guid childId, [FromQuery] DateTime? date)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        try
        {
            var targetDate = date?.Date ?? DateTime.UtcNow.Date;
            var summary = await _reportingService.GetDailySummaryAsync(childId, targetDate);
            return Ok(summary);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun belirtilen haftaya ait haftalık özetini getirir
    /// </summary>
    /// <param name="childId">Çocuk profil ID</param>
    /// <param name="weekStart">Haftanın başlangıç tarihi (yyyy-MM-dd). Belirtilmezse bu haftanın Pazartesi'si kullanılır.</param>
    [HttpGet("{childId}/weekly")]
    public async Task<ActionResult<WeeklySummaryDto>> GetWeeklySummary(Guid childId, [FromQuery] DateTime? weekStart)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        try
        {
            var start = weekStart?.Date ?? GetCurrentWeekMonday();
            var summary = await _reportingService.GetWeeklySummaryAsync(childId, start);
            return Ok(summary);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun en zayıf olduğu konuları getirir
    /// </summary>
    /// <param name="childId">Çocuk profil ID</param>
    /// <param name="topN">Kaç konu getirileceği (varsayılan: 5)</param>
    [HttpGet("{childId}/weak-topics")]
    public async Task<ActionResult<List<WeakTopicDto>>> GetWeakTopics(Guid childId, [FromQuery] int topN = 5)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (topN < 1 || topN > 20)
            return BadRequest(new { message = "topN 1 ile 20 arasında olmalıdır." });

        try
        {
            var topics = await _reportingService.GetWeakTopicsAsync(childId, topN);
            return Ok(topics);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // --- Helpers ---

    /// <summary>
    /// Çocuğun genel etkinlik istatistiklerini getirir (podcast, meydan okuma, ödev)
    /// </summary>
    [HttpGet("{childId}/activity")]
    public async Task<ActionResult<ActivitySummaryDto>> GetActivitySummary(Guid childId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        try
        {
            var summary = await _reportingService.GetActivitySummaryAsync(childId);
            return Ok(summary);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // --- Helpers ---

    private Guid GetUserIdFromToken()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (claim == null)
            throw new UnauthorizedAccessException("Kullanıcı kimliği bulunamadı.");
        return Guid.Parse(claim.Value);
    }

    private async Task<bool> ChildBelongsToCurrentParentAsync(Guid childId)
    {
        var userId = GetUserIdFromToken();
        var children = await _childProfileService.GetChildrenByUserIdAsync(userId);
        return children.Any(c => c.Id == childId);
    }

    private static DateTime GetCurrentWeekMonday()
    {
        var today = DateTime.UtcNow.Date;
        var diff = (7 + (today.DayOfWeek - DayOfWeek.Monday)) % 7;
        return today.AddDays(-diff);
    }
}
