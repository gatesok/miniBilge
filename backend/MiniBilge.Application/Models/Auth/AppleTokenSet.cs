namespace MiniBilge.Application.Models.Auth;

public sealed record AppleTokenSet(
    string AccessToken,
    string? RefreshToken,
    DateTimeOffset ExpiresAt);
