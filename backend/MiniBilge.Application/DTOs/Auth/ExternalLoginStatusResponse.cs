namespace MiniBilge.Application.DTOs.Auth;

public class ExternalLoginStatusResponse
{
    public bool HasPassword { get; set; }
    public IReadOnlyList<string> Providers { get; set; } = [];
}
