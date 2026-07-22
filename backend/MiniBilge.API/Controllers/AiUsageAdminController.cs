using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.API.Controllers;

/// <summary>
/// OpenAI kullanım ve tahmini maliyet raporları. X-Admin-Key gerektirir.
/// Kullanıcı veya çocuk kimliği döndürmez.
/// </summary>
[ApiController]
[Route("api/admin/ai-usage")]
public sealed class AiUsageAdminController : ControllerBase
{
    private const int MaxDateRangeDays = 31;
    private readonly ApplicationDbContext _db;
    private readonly string _adminKey;

    public AiUsageAdminController(ApplicationDbContext db, IConfiguration configuration)
    {
        _db = db;
        _adminKey = configuration["Admin:ApiKey"] ?? string.Empty;
    }

    [HttpGet("summary")]
    [ProducesResponseType<AiUsageSummaryResponse>(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    public async Task<ActionResult<AiUsageSummaryResponse>> GetSummary(
        [FromQuery] DateOnly? from,
        [FromQuery] DateOnly? to,
        CancellationToken cancellationToken)
    {
        if (!IsAdmin())
        {
            return Unauthorized();
        }

        var endDate = to ?? DateOnly.FromDateTime(DateTime.UtcNow);
        var startDate = from ?? endDate.AddDays(-6);
        var dayCount = endDate.DayNumber - startDate.DayNumber + 1;

        if (dayCount <= 0 || dayCount > MaxDateRangeDays)
        {
            return BadRequest(new
            {
                error = $"Tarih aralığı 1-{MaxDateRangeDays} gün arasında olmalıdır."
            });
        }

        var startUtc = startDate.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
        var endExclusiveUtc = endDate.AddDays(1)
            .ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);

        var usage = await _db.AiUsageEvents
            .AsNoTracking()
            .Where(x => !x.IsDeleted &&
                        x.CreatedAt >= startUtc &&
                        x.CreatedAt < endExclusiveUtc)
            .Select(x => new
            {
                x.CreatedAt,
                x.FeatureKey,
                x.Provider,
                x.Model,
                x.Success,
                x.InputTokens,
                x.OutputTokens,
                x.EstimatedCostUsd,
                x.DurationMs
            })
            .ToListAsync(cancellationToken);

        var rows = usage
            .GroupBy(x => new
            {
                Day = x.CreatedAt.Date,
                x.FeatureKey,
                x.Provider,
                x.Model
            })
            .Select(group => new AiUsageSummaryRow(
                DateOnly.FromDateTime(group.Key.Day),
                group.Key.FeatureKey,
                group.Key.Provider,
                group.Key.Model,
                group.Count(),
                group.Count(x => x.Success),
                group.Count(x => !x.Success),
                group.Sum(x => x.InputTokens ?? 0),
                group.Sum(x => x.OutputTokens ?? 0),
                group.Sum(x => x.EstimatedCostUsd ?? 0m),
                group.Sum(x => x.DurationMs)))
            .OrderBy(x => x.Day)
            .ThenBy(x => x.FeatureKey)
            .ThenBy(x => x.Model)
            .ToList();

        return Ok(new AiUsageSummaryResponse(startDate, endDate, rows));
    }

    private bool IsAdmin()
    {
        if (string.IsNullOrWhiteSpace(_adminKey) ||
            !Request.Headers.TryGetValue("X-Admin-Key", out var supplied))
        {
            return false;
        }

        var expectedBytes = Encoding.UTF8.GetBytes(_adminKey);
        var suppliedBytes = Encoding.UTF8.GetBytes(supplied.ToString());
        return expectedBytes.Length == suppliedBytes.Length &&
               CryptographicOperations.FixedTimeEquals(expectedBytes, suppliedBytes);
    }
}

public sealed record AiUsageSummaryResponse(
    DateOnly From,
    DateOnly To,
    IReadOnlyList<AiUsageSummaryRow> Rows);

public sealed record AiUsageSummaryRow(
    DateOnly Day,
    string FeatureKey,
    string Provider,
    string Model,
    int RequestCount,
    int SuccessCount,
    int FailureCount,
    int InputTokens,
    int OutputTokens,
    decimal EstimatedCostUsd,
    long TotalDurationMs);
