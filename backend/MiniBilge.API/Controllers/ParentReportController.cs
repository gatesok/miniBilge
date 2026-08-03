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
    private readonly IEntitlementService _entitlementService;
    private readonly IWeeklyGoalService _weeklyGoalService;

    public ParentReportController(
        IParentReportingService reportingService,
        IChildProfileService childProfileService,
        IEntitlementService entitlementService,
        IWeeklyGoalService weeklyGoalService)
    {
        _reportingService = reportingService;
        _childProfileService = childProfileService;
        _entitlementService = entitlementService;
        _weeklyGoalService = weeklyGoalService;
    }    /// <summary>
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

    /// <summary>
    /// P6-B05: 30/90 günlük gelişim trendi (haftalık kırılım). Yalnızca premium.
    /// </summary>
    /// <param name="childId">Çocuk profil ID</param>
    /// <param name="days">Gün penceresi: 30 veya 90 (varsayılan: 30)</param>
    [HttpGet("{childId}/trend")]
    public async Task<ActionResult<ProgressTrendDto>> GetProgressTrend(Guid childId, [FromQuery] int days = 30)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (days != 30 && days != 90)
            return BadRequest(new { message = "days yalnızca 30 veya 90 olabilir." });

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        try
        {
            var trend = await _reportingService.GetProgressTrendAsync(childId, days);
            return Ok(trend);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// P6-B06: Konu bazlı performans metrikleri (doğruluk, süre, tekrar). Yalnızca premium.
    /// </summary>
    /// <param name="childId">Çocuk profil ID</param>
    /// <param name="days">Gün penceresi: 30 veya 90 (varsayılan: 30)</param>
    [HttpGet("{childId}/topic-performance")]
    public async Task<ActionResult<List<TopicPerformanceDto>>> GetTopicPerformance(Guid childId, [FromQuery] int days = 30)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (days != 30 && days != 90)
            return BadRequest(new { message = "days yalnızca 30 veya 90 olabilir." });

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        try
        {
            var result = await _reportingService.GetTopicPerformanceAsync(childId, days);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// P6-B08: Ebeveyn için aksiyon alınabilir haftalık öneriler. Yalnızca premium.
    /// </summary>
    [HttpGet("{childId}/recommendations")]
    public async Task<ActionResult<List<RecommendationDto>>> GetRecommendations(Guid childId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        try
        {
            var result = await _reportingService.GetWeeklyRecommendationsAsync(childId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// P6-B07: Ebeveynin tüm çocuklarını kapsayan aile özeti. Yalnızca premium.
    /// </summary>
    /// <param name="days">Gün penceresi: 7 veya 30 (varsayılan: 7)</param>
    [HttpGet("family/summary")]
    public async Task<ActionResult<FamilySummaryDto>> GetFamilySummary([FromQuery] int days = 7)
    {
        if (days != 7 && days != 30)
            return BadRequest(new { message = "days yalnızca 7 veya 30 olabilir." });

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        try
        {
            var children = await _childProfileService.GetChildrenByUserIdAsync(GetUserIdFromToken());
            var refs = children.Select(c => (c.Id, c.Name)).ToList();
            var result = await _reportingService.GetFamilySummaryAsync(refs, days);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// P6-B04: Çocuk için haftalık hedefi ve mevcut hafta ilerlemesini getirir. Yalnızca premium.
    /// </summary>
    [HttpGet("{childId}/weekly-goal")]
    public async Task<ActionResult<WeeklyGoalDto>> GetWeeklyGoal(Guid childId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        try
        {
            var result = await _weeklyGoalService.GetWeeklyGoalAsync(childId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// P6-B04: Çocuk için haftalık hedefi belirler/günceller (upsert). Yalnızca premium.
    /// </summary>
    [HttpPut("{childId}/weekly-goal")]
    public async Task<ActionResult<WeeklyGoalDto>> SetWeeklyGoal(Guid childId, [FromBody] SetWeeklyGoalRequest request)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId))
            return Forbid();

        if (!await IsCurrentParentPremiumAsync())
            return PremiumRequired();

        if (request.WeeklyStudyMinutesGoal is < 0 or > 10080)
            return BadRequest(new { message = "WeeklyStudyMinutesGoal 0-10080 aralığında olmalıdır." });

        try
        {
            var result = await _weeklyGoalService.SetWeeklyGoalAsync(
                childId, request.WeeklyStudyMinutesGoal, request.FocusTopicId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // --- Helpers ---

    private async Task<bool> IsCurrentParentPremiumAsync()
    {
        var snapshot = await _entitlementService.GetForUserAsync(GetUserIdFromToken());
        return snapshot.IsPremium;
    }

    private ObjectResult PremiumRequired()
        => StatusCode(403, new
        {
            code = "PREMIUM_REQUIRED",
            message = "Bu detaylı rapor premium üyelere özeldir.",
        });

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
