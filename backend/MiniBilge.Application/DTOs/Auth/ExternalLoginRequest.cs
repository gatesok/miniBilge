using System.ComponentModel.DataAnnotations;

namespace MiniBilge.Application.DTOs.Auth;

public class ExternalLoginRequest
{
    [Required]
    public string IdToken { get; set; } = string.Empty;
}
