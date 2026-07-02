using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Classroom;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class ClassroomsController : ControllerBase
{
    private readonly IClassroomService _service;

    public ClassroomsController(IClassroomService service) => _service = service;

    private Guid CurrentUserId
    {
        get
        {
            var claim = User.FindFirst(ClaimTypes.NameIdentifier)
                     ?? User.FindFirst(System.IdentityModel.Tokens.Jwt.JwtRegisteredClaimNames.Sub);
            if (claim == null || !Guid.TryParse(claim.Value, out var id))
                throw new UnauthorizedAccessException("Kullanıcı kimliği doğrulanamadı.");
            return id;
        }
    }

    // ── POST /api/classrooms ─────────────────────────────────────────────────
    /// <summary>Yeni sınıf oluşturur (sadece öğretmenler).</summary>
    [HttpPost]
    public async Task<IActionResult> Create([FromBody] CreateClassroomDto dto, [FromQuery] Guid childId)
    {
        try
        {
            var result = await _service.CreateClassroomAsync(CurrentUserId, childId, dto.Name);
            return CreatedAtAction(nameof(GetMine), null, result);
        }
        catch (UnauthorizedAccessException ex)
        {
            return Forbid();
        }
        catch (Exception ex)
        {
            var detail = ex.InnerException?.Message ?? ex.Message;
            return BadRequest(new { message = detail });
        }
    }

    // ── POST /api/classrooms/join ────────────────────────────────────────────
    /// <summary>Davet koduyla sınıfa katılır.</summary>
    [HttpPost("join")]
    public async Task<IActionResult> Join([FromBody] JoinClassroomDto dto, [FromQuery] Guid childId)
    {
        try
        {
            var result = await _service.JoinByCodeAsync(dto.InviteCode, childId);
            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ── DELETE /api/classrooms/{id}/leave ───────────────────────────────────
    /// <summary>Sınıftan ayrılır.</summary>
    [HttpDelete("{id}/leave")]
    public async Task<IActionResult> Leave(Guid id, [FromQuery] Guid childId)
    {
        try
        {
            await _service.LeaveAsync(id, childId);
            return NoContent();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ── GET /api/classrooms/mine ─────────────────────────────────────────────
    /// <summary>Kullanıcının sahip olduğu ve üye olduğu sınıfları listeler.</summary>
    [HttpGet("mine")]
    public async Task<IActionResult> GetMine([FromQuery] Guid childId)
    {
        try
        {
            var result = await _service.GetMyClassroomsAsync(childId, CurrentUserId);
            return Ok(result);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ── GET /api/classrooms/{id} ─────────────────────────────────────────────
    /// <summary>Sınıf detayını getirir (üyeler, ödevler, ilerleme).</summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetDetail(Guid id, [FromQuery] Guid childId)
    {
        try
        {
            var result = await _service.GetDetailAsync(id, childId, CurrentUserId);
            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    // ── POST /api/classrooms/{id}/assignments ────────────────────────────────
    /// <summary>Sınıfa ödev atar (sadece sınıf sahibi).</summary>
    [HttpPost("{id}/assignments")]
    public async Task<IActionResult> CreateAssignment(Guid id, [FromBody] CreateAssignmentDto dto)
    {
        try
        {
            var result = await _service.CreateAssignmentAsync(id, CurrentUserId, dto);
            return CreatedAtAction(nameof(GetDetail), new { id }, result);
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
    // ── DELETE /api/classrooms/{id} ──────────────────────────────────────
    /// <summary>Sınıfı siler (sadece sınıf sahibi).</summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(Guid id)
    {
        try
        {
            await _service.DeleteClassroomAsync(id, CurrentUserId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)   { return NotFound(new { message = ex.Message }); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex)              { return BadRequest(new { message = ex.Message }); }
    }

    // ── DELETE /api/classrooms/{id}/members/{childId} ────────────────────
    /// <summary>Üyeyi sınıftan çıkarır (sadece sınıf sahibi).</summary>
    [HttpDelete("{id}/members/{childId}")]
    public async Task<IActionResult> KickMember(Guid id, Guid childId)
    {
        try
        {
            await _service.KickMemberAsync(id, childId, CurrentUserId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)     { return NotFound(new { message = ex.Message }); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (InvalidOperationException ex){ return BadRequest(new { message = ex.Message }); }
        catch (Exception ex)               { return BadRequest(new { message = ex.Message }); }
    }

    // ── DELETE /api/classrooms/{id}/assignments/{assignmentId} ────────────
    /// <summary>Ödevi siler / geri alır (sadece sınıf sahibi).</summary>
    [HttpDelete("{id}/assignments/{assignmentId}")]
    public async Task<IActionResult> DeleteAssignment(Guid id, Guid assignmentId)
    {
        try
        {
            await _service.DeleteAssignmentAsync(id, assignmentId, CurrentUserId);
            return NoContent();
        }
        catch (KeyNotFoundException ex)     { return NotFound(new { message = ex.Message }); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex)               { return BadRequest(new { message = ex.Message }); }
    }

    // ── PUT /api/classrooms/{id}/assignments/{assignmentId} ────────────────
    /// <summary>Ödevi revize eder (başlık / son tarih / min soru sayısı).</summary>
    [HttpPut("{id}/assignments/{assignmentId}")]
    public async Task<IActionResult> UpdateAssignment(
        Guid id, Guid assignmentId, [FromBody] UpdateAssignmentDto dto)
    {
        try
        {
            var result = await _service.UpdateAssignmentAsync(id, assignmentId, CurrentUserId, dto);
            return Ok(result);
        }
        catch (KeyNotFoundException ex)     { return NotFound(new { message = ex.Message }); }
        catch (UnauthorizedAccessException) { return Forbid(); }
        catch (Exception ex)               { return BadRequest(new { message = ex.Message }); }
    }
    // ── GET /api/classrooms/{id}/assignments/{assignmentId}/detail ───────────
    /// <summary>Öğretmen için ödev detayını (her öğrencinin ilerlemesi) getirir.</summary>
    [HttpGet("{id}/assignments/{assignmentId}/detail")]
    public async Task<IActionResult> GetAssignmentDetail(Guid id, Guid assignmentId)
    {
        try
        {
            var result = await _service.GetAssignmentDetailAsync(id, assignmentId, CurrentUserId);
            return Ok(result);
        }
        catch (KeyNotFoundException ex)
        {
            return NotFound(new { message = ex.Message });
        }
        catch (UnauthorizedAccessException)
        {
            return Forbid();
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }
}
