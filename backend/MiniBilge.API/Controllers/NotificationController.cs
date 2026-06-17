using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using MiniBilge.Application.DTOs.Notification;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class NotificationController : ControllerBase
{
    private readonly IDeviceTokenRepository _deviceTokenRepo;
    private readonly INotificationService _notificationService;
    private readonly IChildProfileRepository _childProfileRepo;
    private readonly string _schedulerApiKey;

    public NotificationController(
        IDeviceTokenRepository deviceTokenRepo,
        INotificationService notificationService,
        IChildProfileRepository childProfileRepo,
        IConfiguration configuration)
    {
        _deviceTokenRepo = deviceTokenRepo;
        _notificationService = notificationService;
        _childProfileRepo = childProfileRepo;
        _schedulerApiKey = configuration["Scheduler:ApiKey"] ?? string.Empty;
    }

    /// <summary>
    /// Cihaz FCM token'ını kaydeder veya günceller.
    /// </summary>
    [HttpPost("register")]
    [Authorize]
    public async Task<IActionResult> RegisterToken(
        [FromBody] RegisterDeviceTokenRequest request)
    {
        if (!ModelState.IsValid)
            return BadRequest(ModelState);

        await _deviceTokenRepo.UpsertAsync(
            request.ChildProfileId,
            request.Token,
            request.Platform);

        return Ok(new { message = "Token kaydedildi." });
    }

    /// <summary>
    /// Cloud Scheduler tarafından her gün 18:00'de çağrılır.
    /// Tüm aktif çocuklara günlük hatırlatma bildirimi gönderir.
    /// Header: X-Scheduler-Key
    /// </summary>
    [HttpPost("scheduled/daily-reminder")]
    public async Task<IActionResult> SendDailyReminders()
    {
        if (!IsValidSchedulerRequest())
            return Unauthorized();

        var children = await _childProfileRepo.GetAllAsync();
        var sent = 0;

        foreach (var child in children)
        {
            var tokens = await _deviceTokenRepo.GetTokensByChildIdAsync(child.Id);
            if (!tokens.Any()) continue;

            await _notificationService.SendDailyReminderAsync(child.Id, child.Name);
            sent++;
        }

        return Ok(new { message = $"Günlük hatırlatma gönderildi. Hedef: {sent} profil." });
    }

    /// <summary>
    /// Cloud Scheduler tarafından her gün 20:00'de çağrılır.
    /// Token kaydı olan tüm çocuklara streak uyarısı gönderir
    /// (client-side streak kontrolü yapılır, backend burada toplu gönderim yapar).
    /// Header: X-Scheduler-Key
    /// </summary>
    [HttpPost("scheduled/streak-warning")]
    public async Task<IActionResult> SendStreakWarnings()
    {
        if (!IsValidSchedulerRequest())
            return Unauthorized();

        var allTokens = await _deviceTokenRepo.GetAllActiveTokensAsync();
        var childIds = allTokens.Select(t => t.ChildProfileId).Distinct().ToList();
        var sent = 0;

        foreach (var childId in childIds)
        {
            var child = await _childProfileRepo.GetByIdAsync(childId);
            if (child is null) continue;

            await _notificationService.SendStreakWarningAsync(child.Id, child.Name);
            sent++;
        }

        return Ok(new { message = $"Streak uyarısı gönderildi. Hedef: {sent} profil." });
    }

    private bool IsValidSchedulerRequest()
    {
        if (string.IsNullOrEmpty(_schedulerApiKey)) return false;
        Request.Headers.TryGetValue("X-Scheduler-Key", out var headerValue);
        return headerValue.ToString() == _schedulerApiKey;
    }
}
