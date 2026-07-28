using System.IdentityModel.Tokens.Jwt;
using System.Net.Http.Json;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text.Json.Serialization;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Models.Auth;
using MiniBilge.Infrastructure.Options;

namespace MiniBilge.Infrastructure.Services;

public sealed class AppleTokenService : IAppleTokenService
{
    private const string AppleAudience = "https://appleid.apple.com";
    private const string AppleTokenEndpoint =
        "https://appleid.apple.com/auth/token";
    private const string AppleRevokeEndpoint =
        "https://appleid.apple.com/auth/revoke";

    private readonly HttpClient _httpClient;
    private readonly AppleSignInOptions _options;

    public AppleTokenService(
        HttpClient httpClient,
        IOptions<AppleSignInOptions> options)
    {
        _httpClient = httpClient;
        _options = options.Value;
    }

    public async Task<AppleTokenSet> ExchangeAuthorizationCodeAsync(
        string authorizationCode,
        CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(authorizationCode);

        using var request = new HttpRequestMessage(
            HttpMethod.Post,
            AppleTokenEndpoint)
        {
            Content = new FormUrlEncodedContent(
                new Dictionary<string, string>
                {
                    ["client_id"] = GetRequiredClientId(),
                    ["client_secret"] = CreateClientSecret(),
                    ["code"] = authorizationCode,
                    ["grant_type"] = "authorization_code"
                })
        };

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken);
        var payload = await response.Content.ReadFromJsonAsync<AppleTokenPayload>(
            cancellationToken: cancellationToken);

        if (!response.IsSuccessStatusCode
            || payload is null
            || string.IsNullOrWhiteSpace(payload.AccessToken))
        {
            throw new InvalidOperationException(
                "Apple yetkilendirme kodu doğrulanamadı");
        }

        return new AppleTokenSet(
            payload.AccessToken,
            payload.RefreshToken,
            DateTimeOffset.UtcNow.AddSeconds(payload.ExpiresIn));
    }

    public async Task RevokeAsync(
        string refreshToken,
        CancellationToken cancellationToken = default)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(refreshToken);

        using var request = new HttpRequestMessage(
            HttpMethod.Post,
            AppleRevokeEndpoint)
        {
            Content = new FormUrlEncodedContent(
                new Dictionary<string, string>
                {
                    ["client_id"] = GetRequiredClientId(),
                    ["client_secret"] = CreateClientSecret(),
                    ["token"] = refreshToken,
                    ["token_type_hint"] = "refresh_token"
                })
        };

        using var response = await _httpClient.SendAsync(
            request,
            cancellationToken);
        if (!response.IsSuccessStatusCode)
        {
            throw new InvalidOperationException(
                "Apple hesap bağlantısı iptal edilemedi");
        }
    }

    private string CreateClientSecret()
    {
        var teamId = GetRequired(_options.TeamId, "TeamId");
        var keyId = GetRequired(_options.KeyId, "KeyId");
        var privateKey = GetRequired(_options.PrivateKey, "PrivateKey")
            .Replace("\\n", "\n", StringComparison.Ordinal);
        var clientId = GetRequiredClientId();

        using var ecdsa = ECDsa.Create();
        try
        {
            ecdsa.ImportFromPem(privateKey);
        }
        catch (ArgumentException)
        {
            throw new InvalidOperationException(
                "Apple private key geçersiz");
        }

        var now = DateTimeOffset.UtcNow;
        var credentials = new SigningCredentials(
            new ECDsaSecurityKey(ecdsa)
            {
                KeyId = keyId
            },
            SecurityAlgorithms.EcdsaSha256);
        var token = new JwtSecurityToken(
            issuer: teamId,
            audience: AppleAudience,
            claims:
            [
                new Claim("sub", clientId)
            ],
            notBefore: now.UtcDateTime,
            expires: now.AddMinutes(10).UtcDateTime,
            signingCredentials: credentials);
        token.Header["kid"] = keyId;

        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    private string GetRequiredClientId()
    {
        return GetRequired(_options.ClientId, "ClientId");
    }

    private static string GetRequired(string value, string name)
    {
        if (string.IsNullOrWhiteSpace(value))
        {
            throw new InvalidOperationException(
                $"Apple Sign in {name} yapılandırılmadı");
        }

        return value.Trim();
    }

    private sealed class AppleTokenPayload
    {
        [JsonPropertyName("access_token")]
        public string? AccessToken { get; init; }

        [JsonPropertyName("expires_in")]
        public int ExpiresIn { get; init; }

        [JsonPropertyName("refresh_token")]
        public string? RefreshToken { get; init; }
    }
}
