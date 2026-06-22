using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PodcastController : ControllerBase
{
    private readonly IPodcastService _podcastService;

    public PodcastController(IPodcastService podcastService)
    {
        _podcastService = podcastService;
    }

    /// <summary>
    /// Seviyeye göre podcast episode listesini döndürür.
    /// level: 1=A1, 2=A2, 3=B1, 4=B2, 5=C1, 6=C2
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetByLevel([FromQuery] int level)
    {
        if (level < 1 || level > 6)
            return BadRequest("Geçersiz seviye. 1 (A1) ile 6 (C2) arasında olmalıdır.");

        var episodes = await _podcastService.GetEpisodesByLevelAsync(level);
        return Ok(episodes);
    }

    /// <summary>
    /// Belirli bir episode'un tüm satırlarıyla birlikte detayını döndürür.
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetEpisode(Guid id)
    {
        var episode = await _podcastService.GetEpisodeAsync(id);
        if (episode is null)
            return NotFound("Episode bulunamadı.");

        return Ok(episode);
    }
}
