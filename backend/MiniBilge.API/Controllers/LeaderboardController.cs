using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Leaderboard;
using MiniBilge.Application.Interfaces;
using MiniBilge.Domain.Enums;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly ILeaderboardService _leaderboardService;

    public LeaderboardController(ILeaderboardService leaderboardService)
    {
        _leaderboardService = leaderboardService;
    }

    /// <summary>
    /// Global sıralama listesi (Top 50)
    /// </summary>
    [HttpGet]
    public async Task<ActionResult<List<LeaderboardEntryDto>>> GetLeaderboard(
        [FromQuery] int topN = 50,
        [FromQuery] CompetitionAudience audience = CompetitionAudience.Child)
    {
        try
        {
            var leaderboard = await _leaderboardService.GetGlobalLeaderboardAsync(topN, audience);
            return Ok(leaderboard);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Sıralama yüklenirken hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Belirli bir çocuğun sırasını döner
    /// </summary>
    [HttpGet("child/{childProfileId}/rank")]
    public async Task<ActionResult<LeaderboardEntryDto>> GetChildRank(Guid childProfileId)
    {
        try
        {
            var entry = await _leaderboardService.GetChildRankAsync(childProfileId);
            if (entry == null)
                return NotFound(new { message = "Çocuk profili bulunamadı" });

            return Ok(entry);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Sıra bilgisi alınırken hata oluştu", error = ex.Message });
        }
    }
}
