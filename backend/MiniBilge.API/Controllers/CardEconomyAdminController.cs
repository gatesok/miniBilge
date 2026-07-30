using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/admin/card-economy")]
public sealed class CardEconomyAdminController : ControllerBase
{
    private readonly ApplicationDbContext _db;
    private readonly string _adminKey;

    public CardEconomyAdminController(ApplicationDbContext db, IConfiguration configuration)
    {
        _db = db;
        _adminKey = configuration["Admin:ApiKey"] ?? string.Empty;
    }

    [HttpGet("summary")]
    public async Task<IActionResult> GetSummary([FromQuery] DateOnly? date)
    {
        if (!IsAdmin()) return Unauthorized();
        var day = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var from = day.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var to = from.AddDays(1);
        var rows = await _db.CardEconomyEvents.AsNoTracking()
            .Where(x => x.CreatedAt >= from && x.CreatedAt < to)
            .GroupBy(x => x.Stage)
            .Select(x => new
            {
                Stage = x.Key,
                Attempts = x.Count(),
                Cards = x.Count(e => e.Outcome == "new_card" || e.Outcome == "duplicate"),
                NewCards = x.Count(e => e.Outcome == "new_card"),
                Duplicates = x.Count(e => e.WasDuplicate),
                Guaranteed = x.Count(e => e.WasGuaranteed),
                Shards = x.Sum(e => e.ShardsAwarded),
            })
            .OrderBy(x => x.Stage)
            .ToListAsync();
        return Ok(new { Date = day, Rows = rows });
    }

    private bool IsAdmin()
    {
        if (string.IsNullOrWhiteSpace(_adminKey) ||
            !Request.Headers.TryGetValue("X-Admin-Key", out var supplied)) return false;
        var expected = Encoding.UTF8.GetBytes(_adminKey);
        var actual = Encoding.UTF8.GetBytes(supplied.ToString());
        return expected.Length == actual.Length &&
               CryptographicOperations.FixedTimeEquals(expected, actual);
    }
}
