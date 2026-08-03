using System.Text.Json.Serialization;

namespace MiniBilge.Application.DTOs.Premium;

public sealed class AppleWebhookPayload
{
    [JsonPropertyName("signedPayload")]
    public string? SignedPayload { get; set; }
}
