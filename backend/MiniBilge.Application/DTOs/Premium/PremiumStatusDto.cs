namespace MiniBilge.Application.DTOs.Premium;

public sealed class PremiumStatusDto
{
    public bool IsPremium { get; set; }
    public string? ProductId { get; set; }
    public DateTime? ExpiresAt { get; set; }
}
