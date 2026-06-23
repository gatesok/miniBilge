using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Podcast;
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
    private readonly IPodcastQuizService _quizService;

    public PodcastController(
        IPodcastService podcastService,
        TtsAudioGeneratorService ttsGenerator,
        IPodcastQuizService quizService)
    {
        _podcastService = podcastService;
        _ttsGenerator = ttsGenerator;
        _quizService = quizService;
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

    // ─── Quiz Endpoint'leri ───────────────────────────────────────────────────

    /// <summary>
    /// Episode'a ait quiz sorularını döndürür. CorrectAnswer gönderilmez.
    /// </summary>
    [HttpGet("{id}/questions")]
    public async Task<IActionResult> GetQuestions(Guid id)
    {
        var questions = await _quizService.GetQuestionsAsync(id);
        if (!questions.Any())
            return NotFound("Bu bölüm için soru bulunamadı.");

        return Ok(questions);
    }

    /// <summary>
    /// Quiz cevaplarını değerlendirir, coin/yıldız ekler (ilk tamamlamada).
    /// </summary>
    [HttpPost("{id}/quiz/submit")]
    public async Task<IActionResult> SubmitQuiz(Guid id, [FromBody] PodcastQuizSubmitRequest request)
    {
        if (request.Answers is null || !request.Answers.Any())
            return BadRequest("Cevap listesi boş olamaz.");

        var result = await _quizService.SubmitQuizAsync(request.ChildProfileId, id, request);
        return Ok(result);
    }

    /// <summary>
    /// Çocuğun bu bölüm için önceki quiz sonucunu döndürür.
    /// </summary>
    [HttpGet("{id}/quiz/result")]
    public async Task<IActionResult> GetQuizResult(Guid id, [FromQuery] Guid childProfileId)
    {
        var result = await _quizService.GetLastResultAsync(childProfileId, id);
        if (result is null)
            return NotFound("Henüz tamamlanmış bir quiz bulunamadı.");

        return Ok(result);
    }
}
