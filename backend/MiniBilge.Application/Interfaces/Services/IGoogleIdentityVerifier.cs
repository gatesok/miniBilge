using MiniBilge.Application.Models.Auth;

namespace MiniBilge.Application.Interfaces.Services;

public interface IGoogleIdentityVerifier
{
    Task<ExternalIdentity> VerifyAsync(
        string idToken,
        CancellationToken cancellationToken = default);
}
