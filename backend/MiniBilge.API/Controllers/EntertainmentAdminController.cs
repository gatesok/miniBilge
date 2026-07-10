using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.API.Controllers;

/// <summary>
/// Eğlence oyunları için DB içerik yönetimi (toplu import / istatistik).
/// X-Admin-Key header gerektirir.
/// </summary>
[ApiController]
[Route("api/admin/entertainment")]
public class EntertainmentAdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly string _adminKey;

    public EntertainmentAdminController(ApplicationDbContext db, IConfiguration cfg)
    {
        _db       = db;
        _adminKey = cfg["Admin:ApiKey"] ?? string.Empty;
    }

    // ── Quiz ─────────────────────────────────────────────────────────────────

    [HttpPost("quiz/import")]
    public async Task<IActionResult> ImportQuiz([FromBody] List<QuizImportDto> items)
    {
        if (!IsAdmin()) return Unauthorized();

        var entities = items.Select(i => new EntertainmentQuizQuestion
        {
            CategoryKey   = i.CategoryKey.ToLowerInvariant().Replace(" ", "_"),
            Difficulty    = i.Difficulty,
            QuestionText  = i.QuestionText,
            OptionA       = i.OptionA,
            OptionB       = i.OptionB,
            OptionC       = i.OptionC,
            OptionD       = i.OptionD,
            CorrectAnswer = i.CorrectAnswer.ToUpperInvariant(),
            Explanation   = i.Explanation,
            Language      = i.Language ?? "tr",
            IsActive      = true,
        }).ToList();

        await _db.EntertainmentQuizQuestions.AddRangeAsync(entities);
        await _db.SaveChangesAsync();

        return Ok(new { inserted = entities.Count });
    }

    [HttpGet("quiz/stats")]
    public async Task<IActionResult> QuizStats()
    {
        if (!IsAdmin()) return Unauthorized();
        var stats = await _db.EntertainmentQuizQuestions
            .GroupBy(q => new { q.CategoryKey, q.Difficulty })
            .Select(g => new { g.Key.CategoryKey, g.Key.Difficulty, Count = g.Count() })
            .OrderBy(x => x.CategoryKey).ThenBy(x => x.Difficulty)
            .ToListAsync();
        return Ok(stats);
    }

    // ── Gerçek mi Uydurma mı ─────────────────────────────────────────────────

    [HttpPost("fact-fiction/import")]
    public async Task<IActionResult> ImportFactFiction([FromBody] List<FactFictionImportDto> items)
    {
        if (!IsAdmin()) return Unauthorized();

        var entities = items.Select(i => new EntertainmentFactFiction
        {
            Difficulty  = i.Difficulty,
            Statement   = i.Statement,
            IsReal      = i.IsReal,
            Explanation = i.Explanation,
            Language    = i.Language ?? "tr",
            IsActive    = true,
        }).ToList();

        await _db.EntertainmentFactFictions.AddRangeAsync(entities);
        await _db.SaveChangesAsync();

        return Ok(new { inserted = entities.Count });
    }

    // ── Kim Bu ───────────────────────────────────────────────────────────────

    [HttpPost("kim-bu/import")]
    public async Task<IActionResult> ImportKimBu([FromBody] List<KimBuImportDto> items)
    {
        if (!IsAdmin()) return Unauthorized();

        var entities = items.Select(i => new EntertainmentKimBu
        {
            Difficulty    = i.Difficulty,
            Subject       = i.Subject,
            Hints         = i.Hints,
            Options       = i.Options,
            CorrectAnswer = i.CorrectAnswer,
            Language      = i.Language ?? "tr",
            IsActive      = true,
        }).ToList();

        await _db.EntertainmentKimBus.AddRangeAsync(entities);
        await _db.SaveChangesAsync();

        return Ok(new { inserted = entities.Count });
    }

    // ── Ne Ortak ─────────────────────────────────────────────────────────────

    [HttpPost("ne-ortak/import")]
    public async Task<IActionResult> ImportNeOrtak([FromBody] List<NeOrtakImportDto> items)
    {
        if (!IsAdmin()) return Unauthorized();

        var entities = items.Select(i => new EntertainmentNeOrtak
        {
            Difficulty    = i.Difficulty,
            Clues         = i.Clues,
            Connection    = i.Connection,
            Options       = i.Options,
            CorrectAnswer = i.CorrectAnswer,
            Explanation   = i.Explanation,
            Language      = i.Language ?? "tr",
            IsActive      = true,
        }).ToList();

        await _db.EntertainmentNeOrtaks.AddRangeAsync(entities);
        await _db.SaveChangesAsync();

        return Ok(new { inserted = entities.Count });
    }

    private bool IsAdmin()
    {
        if (string.IsNullOrEmpty(_adminKey)) return false;
        Request.Headers.TryGetValue("X-Admin-Key", out var v);
        return v.ToString() == _adminKey;
    }
}

// ── Import DTOs ───────────────────────────────────────────────────────────────

public class QuizImportDto
{
    public string  CategoryKey   { get; set; } = string.Empty;
    public int     Difficulty    { get; set; }
    public string  QuestionText  { get; set; } = string.Empty;
    public string  OptionA       { get; set; } = string.Empty;
    public string  OptionB       { get; set; } = string.Empty;
    public string  OptionC       { get; set; } = string.Empty;
    public string  OptionD       { get; set; } = string.Empty;
    public string  CorrectAnswer { get; set; } = string.Empty;
    public string? Explanation   { get; set; }
    public string? Language      { get; set; }
}

public class FactFictionImportDto
{
    public int    Difficulty  { get; set; }
    public string Statement   { get; set; } = string.Empty;
    public bool   IsReal      { get; set; }
    public string Explanation { get; set; } = string.Empty;
    public string? Language   { get; set; }
}

public class KimBuImportDto
{
    public int          Difficulty    { get; set; }
    public string       Subject       { get; set; } = string.Empty;
    public List<string> Hints         { get; set; } = [];
    public List<string> Options       { get; set; } = [];
    public string       CorrectAnswer { get; set; } = string.Empty;
    public string?      Language      { get; set; }
}

public class NeOrtakImportDto
{
    public int          Difficulty    { get; set; }
    public List<string> Clues         { get; set; } = [];
    public string       Connection    { get; set; } = string.Empty;
    public List<string> Options       { get; set; } = [];
    public string       CorrectAnswer { get; set; } = string.Empty;
    public string?      Explanation   { get; set; }
    public string?      Language      { get; set; }
}
