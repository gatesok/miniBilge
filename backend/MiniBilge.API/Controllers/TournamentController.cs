using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Tournament;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

/// <summary>P7-M05: Yetişkin haftalık eğlence turnuvası (V1 — yalnızca sıralama).</summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]
public class TournamentController : ControllerBase
{
    private readonly IAdultTournamentService _tournamentService;

    public TournamentController(IAdultTournamentService tournamentService)
        => _tournamentService = tournamentService;

    /// <summary>Turnuva kategorileri.</summary>
    [HttpGet("categories")]
    public ActionResult<IReadOnlyList<TournamentCategoryDto>> GetCategories()
        => Ok(_tournamentService.GetCategories());

    /// <summary>Bu haftanın belirtilen kategori sıralaması.</summary>
    [HttpGet("weekly")]
    public async Task<ActionResult<TournamentWeekDto>> GetWeekly(
        [FromQuery] string category,
        [FromQuery] int topN = 50,
        [FromQuery] Guid? childProfileId = null)
    {
        if (string.IsNullOrWhiteSpace(category))
            return BadRequest(new { message = "Kategori gereklidir" });

        try
        {
            var result = await _tournamentService.GetWeeklyLeaderboardAsync(category, topN, childProfileId);
            return Ok(result);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Turnuva sıralaması yüklenirken hata oluştu", error = ex.Message });
        }
    }
}
