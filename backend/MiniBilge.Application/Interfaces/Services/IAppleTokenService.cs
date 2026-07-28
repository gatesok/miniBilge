using MiniBilge.Application.Models.Auth;

namespace MiniBilge.Application.Interfaces.Services;

public interface IAppleTokenService
{
    Task<AppleTokenSet> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        CancellationToken cancellationToken = default);

    Task RevokeAsync(
        string refreshToken,
        CancellationToken cancellationToken = default);
}
