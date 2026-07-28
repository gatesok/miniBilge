using MiniBilge.Application.Models.Auth;

namespace MiniBilge.Application.Interfaces.Services;

public interface IAppleIdentityVerifier
{
    Task<ExternalIdentity> VerifyAsync(
        string identityToken,
        string rawNonce,
        CancellationToken cancellationToken = default);
}
