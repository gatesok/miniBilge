using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Experience;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Authorize]
[Route("api/experience-mode")]
public sealed class ExperienceModeController : ControllerBase
{
    private readonly IExperienceModeService _experienceModeService;

    public ExperienceModeController(IExperienceModeService experienceModeService)
    {
        _experienceModeService = experienceModeService;
    }

    [HttpGet]
    public async Task<ActionResult<ExperienceModeDto>> Get(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        var result = await _experienceModeService.GetAsync(userId, cancellationToken);
        return result is null
            ? NotFound(new { message = "Kullanıcı bulunamadı" })
            : Ok(result);
    }

    [HttpPut]
    public async Task<ActionResult<ExperienceModeDto>> Update(
        [FromBody] UpdateExperienceModeRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        try
        {
            var result = await _experienceModeService.UpdateAsync(
                userId,
                request.Mode,
                cancellationToken);

            return result is null
                ? NotFound(new { message = "Kullanıcı bulunamadı" })
                : Ok(result);
        }
        catch (ArgumentException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out Guid userId)
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        return Guid.TryParse(claim?.Value, out userId);
    }
}
