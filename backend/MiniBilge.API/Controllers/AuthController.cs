using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using FluentValidation;
using MiniBilge.Application.DTOs.Auth;
using MiniBilge.Application.Interfaces.Services;
using System.Security.Claims;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class AuthController : ControllerBase
{
    //test
    private readonly IAuthService _authService;
    private readonly IExternalAuthService _externalAuthService;
    private readonly IValidator<RegisterRequest> _registerValidator;

    public AuthController(
        IAuthService authService,
        IExternalAuthService externalAuthService,
        IValidator<RegisterRequest> registerValidator)
    {
        _authService = authService;
        _externalAuthService = externalAuthService;
        _registerValidator = registerValidator;
    }

    /// <summary>
    /// Yeni kullanıcı kaydı oluşturur
    /// </summary>
    [HttpPost("register")]
    public async Task<ActionResult<AuthResponse>> Register([FromBody] RegisterRequest request)
    {
        var validation = await _registerValidator.ValidateAsync(request);
        if (!validation.IsValid)
            return BadRequest(new { message = validation.Errors.First().ErrorMessage });

        try
        {
            var response = await _authService.RegisterAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Kullanıcı girişi yapar
    /// </summary>
    [HttpPost("login")]
    public async Task<ActionResult<AuthResponse>> Login([FromBody] LoginRequest request)
    {
        try
        {
            var response = await _authService.LoginAsync(request);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Google ID token ile kullanıcı girişi veya yeni hesap oluşturma
    /// </summary>
    [HttpPost("external/google")]
    public async Task<ActionResult<AuthResponse>> LoginWithGoogle(
        [FromBody] ExternalLoginRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _externalAuthService.LoginWithGoogleAsync(
                request,
                cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Apple kimlik bilgisi ile kullanıcı girişi veya yeni hesap oluşturma
    /// </summary>
    [HttpPost("external/apple")]
    public async Task<ActionResult<AuthResponse>> LoginWithApple(
        [FromBody] AppleLoginRequest request,
        CancellationToken cancellationToken)
    {
        try
        {
            var response = await _externalAuthService.LoginWithAppleAsync(
                request,
                cancellationToken);
            return Ok(response);
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize]
    [HttpPost("external/google/link")]
    public async Task<IActionResult> LinkGoogle(
        [FromBody] ExternalLoginRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        try
        {
            await _externalAuthService.LinkGoogleAsync(
                userId,
                request,
                cancellationToken);
            return Ok(new { message = "Google hesabı bağlandı" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize]
    [HttpPost("external/apple/link")]
    public async Task<IActionResult> LinkApple(
        [FromBody] AppleLoginRequest request,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        try
        {
            await _externalAuthService.LinkAppleAsync(
                userId,
                request,
                cancellationToken);
            return Ok(new { message = "Apple hesabı bağlandı" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize]
    [HttpGet("external")]
    public async Task<ActionResult<ExternalLoginStatusResponse>>
        GetExternalLoginStatus(CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        try
        {
            return Ok(await _externalAuthService.GetStatusAsync(
                userId,
                cancellationToken));
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    [Authorize]
    [HttpDelete("external/{provider}")]
    public async Task<IActionResult> UnlinkExternalLogin(
        string provider,
        CancellationToken cancellationToken)
    {
        if (!TryGetUserId(out var userId))
        {
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });
        }

        try
        {
            await _externalAuthService.UnlinkAsync(
                userId,
                provider,
                cancellationToken);
            return Ok(new { message = "Giriş yöntemi kaldırıldı" });
        }
        catch (InvalidOperationException ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Access token yeniler
    /// </summary>
    [HttpPost("refresh")]
    public async Task<ActionResult<AuthResponse>> RefreshToken([FromBody] RefreshTokenRequest request)
    {
        try
        {
            var response = await _authService.RefreshTokenAsync(request.RefreshToken);
            return Ok(response);
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Kullanıcı çıkışı yapar
    /// </summary>
    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromBody] RefreshTokenRequest request)
    {
        try
        {
            await _authService.LogoutAsync(request.RefreshToken);
            return Ok(new { message = "Çıkış başarılı" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Şifre sıfırlama kodu gönderir
    /// </summary>
    [HttpPost("forgot-password")]
    public async Task<IActionResult> ForgotPassword([FromBody] ForgotPasswordRequest request)
    {
        try
        {
            await _authService.ForgotPasswordAsync(request);
            return Ok(new { message = "Şifre sıfırlama kodu e-posta adresinize gönderildi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Şifreyi sıfırlar
    /// </summary>
    [HttpPost("reset-password")]
    public async Task<IActionResult> ResetPassword([FromBody] ResetPasswordRequest request)
    {
        try
        {
            await _authService.ResetPasswordAsync(request);
            return Ok(new { message = "Şifreniz başarıyla güncellendi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    /// <summary>
    /// Kullanıcı hesabını ve tüm verilerini siler (soft delete)
    /// </summary>
    [Authorize]
    [HttpDelete("account")]
    public async Task<IActionResult> DeleteAccount()
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier) ?? User.FindFirst("sub");
        if (userIdClaim == null || !Guid.TryParse(userIdClaim.Value, out var userId))
            return Unauthorized(new { message = "Kullanıcı kimliği doğrulanamadı" });

        try
        {
            await _authService.DeleteAccountAsync(userId);
            return Ok(new { message = "Hesabınız başarıyla silindi" });
        }
        catch (Exception ex)
        {
            return BadRequest(new { message = ex.Message });
        }
    }

    private bool TryGetUserId(out Guid userId)
    {
        var userIdClaim = User.FindFirst(ClaimTypes.NameIdentifier)
            ?? User.FindFirst("sub");
        return Guid.TryParse(userIdClaim?.Value, out userId);
    }
}

public class RefreshTokenRequest
{
    public string RefreshToken { get; set; } = string.Empty;
}
