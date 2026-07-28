using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Models.Auth;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Options;
using System.IdentityModel.Tokens.Jwt;

namespace MiniBilge.Infrastructure.Services;

public class AppleIdentityVerifier : IAppleIdentityVerifier
{
    private const string AppleIssuer = "https://appleid.apple.com";
    private const string AppleConfigurationUrl =
        "https://appleid.apple.com/.well-known/openid-configuration";

    private readonly AppleSignInOptions _options;
    private readonly IConfigurationManager<OpenIdConnectConfiguration>
        _configurationManager;

    public AppleIdentityVerifier(IOptions<AppleSignInOptions> options)
    {
        _options = options.Value;
        _configurationManager =
            new ConfigurationManager<OpenIdConnectConfiguration>(
                AppleConfigurationUrl,
                new OpenIdConnectConfigurationRetriever());
    }

    public async Task<ExternalIdentity> VerifyAsync(
        string identityToken,
        string rawNonce,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(identityToken)
            || string.IsNullOrWhiteSpace(rawNonce))
        {
            throw new InvalidOperationException("Apple kimlik bilgisi eksik");
        }

        if (string.IsNullOrWhiteSpace(_options.ClientId))
        {
            throw new InvalidOperationException("Apple ile giriş henüz yapılandırılmadı");
        }

        try
        {
            var configuration = await _configurationManager.GetConfigurationAsync(
                cancellationToken);

            var tokenHandler = new JwtSecurityTokenHandler
            {
                MapInboundClaims = false
            };

            var principal = tokenHandler.ValidateToken(
                identityToken,
                new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = AppleIssuer,
                    ValidateAudience = true,
                    ValidAudience = _options.ClientId,
                    ValidateLifetime = true,
                    RequireExpirationTime = true,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKeys = configuration.SigningKeys,
                    ClockSkew = TimeSpan.FromMinutes(2)
                },
                out _);

            ValidateNonce(principal, rawNonce);

            var subject = GetRequiredClaim(principal, "sub");
            var email = GetRequiredClaim(principal, "email")
                .Trim()
                .ToLowerInvariant();
            var emailVerified = ParseBooleanClaim(
                principal.FindFirst("email_verified")?.Value);

            if (!emailVerified)
            {
                throw new InvalidOperationException(
                    "Doğrulanmış Apple e-postası bulunamadı");
            }

            return new ExternalIdentity(
                ExternalAuthProvider.Apple,
                subject,
                email,
                true,
                null,
                null,
                ParseBooleanClaim(principal.FindFirst("is_private_email")?.Value));
        }
        catch (InvalidOperationException)
        {
            throw;
        }
        catch (Exception ex) when (
            ex is SecurityTokenException
            or ArgumentException
            or InvalidOperationException)
        {
            throw new InvalidOperationException(
                "Apple oturumu doğrulanamadı");
        }
    }

    private static void ValidateNonce(
        ClaimsPrincipal principal,
        string rawNonce)
    {
        var tokenNonce = GetRequiredClaim(principal, "nonce")
            .Trim()
            .ToLowerInvariant();
        var expectedNonce = Convert.ToHexString(
                SHA256.HashData(Encoding.UTF8.GetBytes(rawNonce)))
            .ToLowerInvariant();

        var tokenBytes = Encoding.UTF8.GetBytes(tokenNonce);
        var expectedBytes = Encoding.UTF8.GetBytes(expectedNonce);

        if (tokenBytes.Length != expectedBytes.Length
            || !CryptographicOperations.FixedTimeEquals(
                tokenBytes,
                expectedBytes))
        {
            throw new InvalidOperationException(
                "Apple güvenlik doğrulaması başarısız");
        }
    }

    private static string GetRequiredClaim(
        ClaimsPrincipal principal,
        string claimType)
    {
        var value = principal.FindFirst(claimType)?.Value;
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException(
                "Apple kimlik bilgisi eksik");
        }

        return value;
    }

    private static bool ParseBooleanClaim(string? value)
    {
        return string.Equals(value, "true", StringComparison.OrdinalIgnoreCase)
            || string.Equals(value, "1", StringComparison.Ordinal);
    }
}
