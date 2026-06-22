using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Services;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class PodcastController : ControllerBase
{
    private readonly IPodcastService _podcastService;
    private readonly TtsAudioGeneratorService _ttsGenerator;

    public PodcastController(IPodcastService podcastService, TtsAudioGeneratorService ttsGenerator)
    {
        _podcastService = podcastService;
        _ttsGenerator = ttsGenerator;
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

    /// <summary>
    /// Episode'un tüm satırları için TTS ses dosyası üretir ve Cloud Storage'a yükler.
    /// Idempotent: zaten AudioUrl'i olan satırlar atlanır.
    /// Admin işlemi — JWT gerektirir.
    /// </summary>
    [HttpPost("{id}/generate-audio")]
    public async Task<IActionResult> GenerateAudio(Guid id, CancellationToken ct)
    {
        try
        {
            await _ttsGenerator.GenerateForEpisodeAsync(id, ct);
            return Ok(new { Message = "Ses üretimi tamamlandı.", EpisodeId = id });
        }
        catch (InvalidOperationException ex)
        {
            return NotFound(ex.Message);
        }
    }
}
