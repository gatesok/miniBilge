using Google.Apis.Auth;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Models.Auth;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Options;

namespace MiniBilge.Infrastructure.Services;

public class GoogleIdentityVerifier : IGoogleIdentityVerifier
{
    private readonly GoogleAuthOptions _options;

    public GoogleIdentityVerifier(IOptions<GoogleAuthOptions> options)
    {
        _options = options.Value;
    }

    public async Task<ExternalIdentity> VerifyAsync(
        string idToken,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(idToken))
        {
            throw new InvalidOperationException("Google kimlik bilgisi eksik");
        }

        var allowedClientIds = _options.GetAllowedClientIds();
        if (allowedClientIds.Count == 0)
        {
            throw new InvalidOperationException("Google ile giriş henüz yapılandırılmadı");
        }

        GoogleJsonWebSignature.Payload payload;
        try
        {
            payload = await GoogleJsonWebSignature.ValidateAsync(
                idToken,
                new GoogleJsonWebSignature.ValidationSettings
                {
                    Audience = allowedClientIds
                });
        }
        catch (InvalidJwtException)
        {
            throw new InvalidOperationException("Google oturumu doğrulanamadı");
        }

        if (string.IsNullOrWhiteSpace(payload.Subject)
            || string.IsNullOrWhiteSpace(payload.Email)
            || payload.EmailVerified is not true)
        {
            throw new InvalidOperationException("Doğrulanmış Google e-postası bulunamadı");
        }

        return new ExternalIdentity(
            ExternalAuthProvider.Google,
            payload.Subject,
            payload.Email.Trim().ToLowerInvariant(),
            payload.EmailVerified,
            payload.GivenName,
            payload.FamilyName,
            false);
    }
}
