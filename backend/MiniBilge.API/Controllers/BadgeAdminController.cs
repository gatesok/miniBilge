using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

/// <summary>
/// Rozet yönetim işlemleri. X-Admin-Key header gerektirir.
/// </summary>
[ApiController]
[Route("api/admin/badges")]
public sealed class BadgeAdminController : ControllerBase
{
    private readonly IBadgeBackfillService _backfillService;
    private readonly IBadgeReportService _reportService;
    private readonly string _adminKey;

    public BadgeAdminController(
        IBadgeBackfillService backfillService,
        IBadgeReportService reportService,
        IConfiguration configuration)
    {
        _backfillService = backfillService;
        _reportService = reportService;
        _adminKey = configuration["Admin:ApiKey"] ?? string.Empty;
    }

    /// <summary>
    /// Rozet kazanım raporu: rozet başına kazanım, oyun türü oranı,
    /// çocuk/yetişkin dağılımı ve hiç kazanılmayan / aşırı kolay rozet uyarıları.
    /// </summary>
    [HttpGet("report")]
    public async Task<IActionResult> Report(
        [FromQuery] double tooEasyThreshold = 0.8, CancellationToken cancellationToken = default)
    {
        if (!IsAdmin()) return Unauthorized();
        var report = await _reportService.GetReportAsync(tooEasyThreshold, cancellationToken);
        return Ok(report);
    }

    /// <summary>
    /// Sprint 2 rozet ailelerini mevcut profillere geriye dönük verir.
    /// Varsayılan olarak yalnızca rapor (dry-run) modunda çalışır; gerçek kayıt
    /// için <c>apply=true</c> verilmelidir. Idempotenttir, güvenle tekrar çalıştırılabilir.
    /// </summary>
    [HttpPost("backfill")]
    public async Task<IActionResult> Backfill([FromQuery] bool apply = false, CancellationToken cancellationToken = default)
    {
        if (!IsAdmin()) return Unauthorized();
        var report = await _backfillService.RunAsync(apply, cancellationToken);
        return Ok(report);
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
