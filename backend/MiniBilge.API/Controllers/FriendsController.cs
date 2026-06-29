using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Friendship;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class FriendsController : ControllerBase
{
    private readonly IFriendshipService _friendshipService;

    public FriendsController(IFriendshipService friendshipService)
        => _friendshipService = friendshipService;

    // ── GET /api/friends?childId={} ──────────────────────────────────────────

    /// <summary>Kabul edilmiş arkadaş listesini getirir.</summary>
    [HttpGet]
    public async Task<IActionResult> GetFriends([FromQuery] Guid childId)
    {
        try
        {
            var friends = await _friendshipService.GetFriendsAsync(childId);
            return Ok(friends);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    // ── GET /api/friends/requests?childId={} ────────────────────────────────

    /// <summary>Bekleyen gelen arkadaşlık isteklerini getirir.</summary>
    [HttpGet("requests")]
    public async Task<IActionResult> GetPendingRequests([FromQuery] Guid childId)
    {
        try
        {
            var requests = await _friendshipService.GetPendingRequestsAsync(childId);
            return Ok(requests);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = ex.Message });
        }
    }

    // ── GET /api/friends/search?requesterId={}&code={} ──────────────────────

    /// <summary>FriendCode ile profil arar, mevcut arkadaşlık durumunu döner.</summary>
    [HttpGet("search")]
    public async Task<IActionResult> SearchByCode(
        [FromQuery] Guid requesterId,
        [FromQuery] string code)
    {
        try
        {
            var result = await _friendshipService.SearchByCodeAsync(requesterId, code);
            if (result == null)
                return NotFound(new { message = "Bu kod ile kayıtlı profil bulunamadı." });
            return Ok(result);
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

    // ── POST /api/friends/request ────────────────────────────────────────────

    /// <summary>FriendCode ile arkadaşlık isteği gönderir.</summary>
    [HttpPost("request")]
    public async Task<IActionResult> SendRequest([FromBody] SendFriendRequestDto request)
    {
        try
        {
            var friendship = await _friendshipService.SendRequestAsync(
                request.RequesterId, request.FriendCode);
            return Ok(friendship);
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

    // ── PUT /api/friends/{id}/respond ────────────────────────────────────────

    /// <summary>Arkadaşlık isteğini kabul veya reddeder.</summary>
    [HttpPut("{id}/respond")]
    public async Task<IActionResult> Respond(Guid id, [FromBody] RespondFriendRequestDto request)
    {
        try
        {
            await _friendshipService.RespondAsync(id, request.AddresseeId, request.Accept);
            return Ok(new { message = request.Accept ? "Arkadaşlık kabul edildi." : "İstek reddedildi." });
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid();
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

    // ── DELETE /api/friends/{id}?childId={} ─────────────────────────────────

    /// <summary>Arkadaşlığı kaldırır (soft-delete).</summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Remove(Guid id, [FromQuery] Guid childId)
    {
        try
        {
            await _friendshipService.RemoveAsync(id, childId);
            return Ok(new { message = "Arkadaşlık kaldırıldı." });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
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

    // ── PUT /api/friends/{id}/block?blockerId={} ────────────────────────────

    /// <summary>Kişiyi engeller.</summary>
    [HttpPut("{id}/block")]
    public async Task<IActionResult> Block(Guid id, [FromQuery] Guid blockerId)
    {
        try
        {
            await _friendshipService.BlockAsync(id, blockerId);
            return Ok(new { message = "Kullanıcı engellendi." });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
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
}
