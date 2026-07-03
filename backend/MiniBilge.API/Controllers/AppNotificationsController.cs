using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Notification;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/notifications")]
[Authorize(Roles = "Parent")]
public class AppNotificationsController : ControllerBase
{
    private readonly IAppNotificationRepository _notifRepo;
    private readonly IChildProfileService _childProfileService;

    public AppNotificationsController(
        IAppNotificationRepository notifRepo,
        IChildProfileService childProfileService)
    {
        _notifRepo          = notifRepo;
        _childProfileService = childProfileService;
    }

    /// <summary>Çocuğun bildirimlerini getirir (son 50).</summary>
    [HttpGet("{childId}")]
    public async Task<ActionResult<List<AppNotificationDto>>> GetNotifications(
        Guid childId, [FromQuery] int limit = 50)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId)) return Forbid();

        var items = await _notifRepo.GetByChildAsync(childId, limit);
        var dtos  = items.Select(n => new AppNotificationDto
        {
            Id               = n.Id,
            Title            = n.Title,
            Body             = n.Body,
            NotificationType = n.NotificationType,
            IsRead           = n.IsRead,
            CreatedAt        = n.CreatedAt,
        }).ToList();

        return Ok(dtos);
    }

    /// <summary>Okunmamış bildirim sayısını döner.</summary>
    [HttpGet("{childId}/unread-count")]
    public async Task<ActionResult<int>> GetUnreadCount(Guid childId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId)) return Forbid();
        return Ok(await _notifRepo.GetUnreadCountAsync(childId));
    }

    /// <summary>Tüm bildirimleri okundu olarak işaretler.</summary>
    [HttpPost("{childId}/mark-all-read")]
    public async Task<IActionResult> MarkAllRead(Guid childId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId)) return Forbid();
        await _notifRepo.MarkAllReadAsync(childId);
        return NoContent();
    }

    /// <summary>Bildirimi siler (soft delete).</summary>
    [HttpDelete("{childId}/{notificationId}")]
    public async Task<IActionResult> Delete(Guid childId, Guid notificationId)
    {
        if (!await ChildBelongsToCurrentParentAsync(childId)) return Forbid();
        await _notifRepo.DeleteAsync(notificationId);
        return NoContent();
    }

    // ── Helpers ─────────────────────────────────────────────────────────────

    private Guid GetUserIdFromToken()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (claim == null) throw new UnauthorizedAccessException();
        return Guid.Parse(claim.Value);
    }

    private async Task<bool> ChildBelongsToCurrentParentAsync(Guid childId)
    {
        var userId   = GetUserIdFromToken();
        var children = await _childProfileService.GetChildrenByUserIdAsync(userId);
        return children.Any(c => c.Id == childId);
    }
}
