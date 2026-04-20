using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Profile;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Parent")]
public class ChildProfileController : ControllerBase
{
    private readonly IChildProfileService _childProfileService;

    public ChildProfileController(IChildProfileService childProfileService)
    {
        _childProfileService = childProfileService;
    }

    /// <summary>
    /// Ebeveyne ait tüm çocukları getirir
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<ChildProfileDto>>> GetChildren()
    {
        try
        {
            var userId = GetUserIdFromToken();
            var children = await _childProfileService.GetChildrenByUserIdAsync(userId);
            return Ok(children);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Belirli bir çocuk profilini getirir
    /// </summary>
    [HttpGet("{id}")]
    public async Task<ActionResult<ChildProfileDto>> GetChild(Guid id)
    {
        try
        {
            var child = await _childProfileService.GetChildByIdAsync(id);
            return Ok(child);
        }
        catch (Exception ex)
        {
            return NotFound(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Yeni çocuk profili oluşturur
    /// </summary>
    [HttpPost]
    public async Task<ActionResult<ChildProfileDto>> CreateChild([FromBody] CreateChildProfileRequest request)
    {
        try
        {
            var userId = GetUserIdFromToken();
            var child = await _childProfileService.CreateChildAsync(userId, request);
            return CreatedAtAction(nameof(GetChild), new { id = child.Id }, child);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuk profilini günceller
    /// </summary>
    [HttpPut("{id}")]
    public async Task<ActionResult<ChildProfileDto>> UpdateChild(Guid id, [FromBody] CreateChildProfileRequest request)
    {
        try
        {
            var child = await _childProfileService.UpdateChildAsync(id, request);
            return Ok(child);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Çocuk profilini siler
    /// </summary>
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteChild(Guid id)
    {
        try
        {
            await _childProfileService.DeleteChildAsync(id);
            return Ok(new { message = "Çocuk profili silindi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private Guid GetUserIdFromToken()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) ?? 
                          User.FindFirst("sub");
        if (userIdClaim == null)
        {
            throw new Exception("Kullanıcı kimliği bulunamadı");
        }
        return Guid.Parse(userIdClaim.Value);
    }
}
