using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Controllers;

/// <summary>
/// Premium/abonelik yönetim uçları. X-Admin-Key gerektirir.
/// </summary>
[ApiController]
[Route("api/admin/premium")]
public sealed class PremiumAdminController : ControllerBase
{
    private readonly IApplePurchaseVerifier _appleVerifier;
    private readonly string _adminKey;

    public PremiumAdminController(
        IApplePurchaseVerifier appleVerifier,
        IConfiguration configuration)
    {
        _appleVerifier = appleVerifier;
        _adminKey = configuration["Admin:ApiKey"] ?? string.Empty;
    }

    /// <summary>Apple'dan webhook URL'ine imzalı bir TEST bildirimi gönderilmesini ister.</summary>
    [HttpPost("apple-test-notification")]
    public async Task<IActionResult> RequestAppleTestNotification(
        CancellationToken cancellationToken)
    {
        if (!IsAdmin())
            return Unauthorized();

        try
        {
            var result = await _appleVerifier.RequestTestNotificationAsync(cancellationToken);
            return Ok(new { environment = result.Environment, token = result.Token });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>İstenen test bildiriminin Apple tarafındaki teslim durumunu döner.</summary>
    [HttpGet("apple-test-notification/{environment}/{token}")]
    public async Task<IActionResult> GetAppleTestNotificationStatus(
        string environment,
        string token,
        CancellationToken cancellationToken)
    {
        if (!IsAdmin())
            return Unauthorized();

        try
        {
            var status = await _appleVerifier.GetTestNotificationStatusAsync(
                environment, token, cancellationToken);
            return Content(status, "application/json");
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
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
