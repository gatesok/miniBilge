using System.ComponentModel.DataAnnotations;

namespace MiniBilge.Application.DTOs.Auth;

public class AppleLoginRequest
{
    [Required]
    public string IdentityToken { get; set; } = string.Empty;

    [Required]
    public string AuthorizationCode { get; set; } = string.Empty;

    [Required]
    public string Nonce { get; set; } = string.Empty;

    public string? FirstName { get; set; }
    public string? LastName { get; set; }
}
