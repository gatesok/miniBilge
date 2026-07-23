using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Http.Headers;
using System.Security.Cryptography;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

public sealed class ApplePurchaseVerifier : IApplePurchaseVerifier
{
    private const string ProductionUrl = "https://api.storekit.itunes.apple.com";
    private const string SandboxUrl = "https://api.storekit-sandbox.itunes.apple.com";
    private readonly HttpClient _httpClient;
    private readonly AppleStoreOptions _options;

    public ApplePurchaseVerifier(
        HttpClient httpClient,
        IOptions<AppleStoreOptions> options)
    {
        _httpClient = httpClient;
        _options = options.Value;
    }

    public async Task<VerifiedAppleTransaction> VerifyAsync(
        string transactionId,
        CancellationToken cancellationToken = default)
    {
        EnsureConfigured();

        var response = await GetTransactionAsync(
            ProductionUrl, transactionId, cancellationToken);
        if (response.StatusCode == HttpStatusCode.NotFound)
        {
            response.Dispose();
            response = await GetTransactionAsync(
                SandboxUrl, transactionId, cancellationToken);
        }

        using (response)
        {
            var body = await response.Content.ReadAsStringAsync(cancellationToken);
            if (!response.IsSuccessStatusCode)
                throw new InvalidOperationException(
                    $"Apple satın alma doğrulaması başarısız ({(int)response.StatusCode}).");

            using var document = JsonDocument.Parse(body);
            var signedInfo = document.RootElement
                .GetProperty("signedTransactionInfo")
                .GetString();
            if (string.IsNullOrWhiteSpace(signedInfo))
                throw new InvalidOperationException("Apple işlem bilgisi boş döndü.");

            return ParseTransaction(signedInfo);
        }
    }

    private async Task<HttpResponseMessage> GetTransactionAsync(
        string baseUrl,
        string transactionId,
        CancellationToken cancellationToken)
    {
        using var request = new HttpRequestMessage(
            HttpMethod.Get,
            $"{baseUrl}/inApps/v1/transactions/{Uri.EscapeDataString(transactionId)}");
        request.Headers.Authorization =
            new AuthenticationHeaderValue("Bearer", CreateApiToken());
        return await _httpClient.SendAsync(request, cancellationToken);
    }

    private string CreateApiToken()
    {
        using var ecdsa = ECDsa.Create();
        ecdsa.ImportFromPem(_options.PrivateKey.Replace("\\n", "\n"));

        var credentials = new SigningCredentials(
            new ECDsaSecurityKey(ecdsa), SecurityAlgorithms.EcdsaSha256);
        var now = DateTime.UtcNow;
        var header = new JwtHeader(credentials)
        {
            ["kid"] = _options.KeyId,
            ["typ"] = "JWT",
        };
        var payload = new JwtPayload
        {
            { "iss", _options.IssuerId },
            { "iat", new DateTimeOffset(now).ToUnixTimeSeconds() },
            { "exp", new DateTimeOffset(now.AddMinutes(5)).ToUnixTimeSeconds() },
            { "aud", "appstoreconnect-v1" },
            { "bid", _options.BundleId },
        };
        return new JwtSecurityTokenHandler()
            .WriteToken(new JwtSecurityToken(header, payload));
    }

    private VerifiedAppleTransaction ParseTransaction(string signedInfo)
    {
        var parts = signedInfo.Split('.');
        if (parts.Length != 3)
            throw new InvalidOperationException("Apple işlem imzası geçersiz.");

        var payloadBytes = Base64UrlEncoder.DecodeBytes(parts[1]);
        using var document = JsonDocument.Parse(payloadBytes);
        var root = document.RootElement;

        var bundleId = GetRequiredString(root, "bundleId");
        if (!string.Equals(bundleId, _options.BundleId, StringComparison.Ordinal))
            throw new InvalidOperationException("Satın alma farklı bir uygulamaya ait.");

        var productId = GetRequiredString(root, "productId");
        if (productId != _options.MonthlyProductId &&
            productId != _options.YearlyProductId)
            throw new InvalidOperationException("Geçersiz Premium ürünü.");

        Guid? appAccountToken = null;
        if (root.TryGetProperty("appAccountToken", out var accountElement) &&
            Guid.TryParse(accountElement.GetString(), out var parsedToken))
            appAccountToken = parsedToken;

        return new VerifiedAppleTransaction(
            GetRequiredString(root, "transactionId"),
            GetRequiredString(root, "originalTransactionId"),
            productId,
            root.TryGetProperty("environment", out var environment)
                ? environment.GetString() ?? "Production"
                : "Production",
            FromUnixMilliseconds(root, "purchaseDate"),
            FromUnixMilliseconds(root, "expiresDate"),
            TryFromUnixMilliseconds(root, "revocationDate"),
            appAccountToken);
    }

    private static string GetRequiredString(JsonElement root, string property)
    {
        if (!root.TryGetProperty(property, out var value) ||
            string.IsNullOrWhiteSpace(value.GetString()))
            throw new InvalidOperationException($"Apple işleminde {property} eksik.");
        return value.GetString()!;
    }

    private static DateTime FromUnixMilliseconds(JsonElement root, string property)
    {
        if (!root.TryGetProperty(property, out var value) ||
            !value.TryGetInt64(out var milliseconds))
            throw new InvalidOperationException($"Apple işleminde {property} eksik.");
        return DateTimeOffset.FromUnixTimeMilliseconds(milliseconds).UtcDateTime;
    }

    private static DateTime? TryFromUnixMilliseconds(
        JsonElement root,
        string property)
    {
        return root.TryGetProperty(property, out var value) &&
               value.TryGetInt64(out var milliseconds)
            ? DateTimeOffset.FromUnixTimeMilliseconds(milliseconds).UtcDateTime
            : null;
    }

    private void EnsureConfigured()
    {
        if (string.IsNullOrWhiteSpace(_options.IssuerId) ||
            string.IsNullOrWhiteSpace(_options.KeyId) ||
            string.IsNullOrWhiteSpace(_options.BundleId) ||
            string.IsNullOrWhiteSpace(_options.PrivateKey))
            throw new InvalidOperationException(
                "Apple Store Server API ayarları yapılandırılmamış.");
    }
}
