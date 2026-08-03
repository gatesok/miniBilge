using System.Net.Http.Headers;
using System.Text.Json;
using Google.Apis.Auth.OAuth2;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// purchases.subscriptionsv2.get çağrısını ADC (Cloud Run runtime SA) ile yapar.
/// JSON anahtar dosyası gerektirmez; yetki Play Console'da SA'ya verilir.
/// </summary>
public sealed class GooglePlayPurchaseVerifier : IGooglePlayPurchaseVerifier
{
    private const string Scope = "https://www.googleapis.com/auth/androidpublisher";
    private const string ApiBase = "https://androidpublisher.googleapis.com";

    private readonly HttpClient _httpClient;
    private readonly GooglePlayOptions _options;
    private readonly SemaphoreSlim _credentialLock = new(1, 1);
    private ITokenAccess? _credential;

    public GooglePlayPurchaseVerifier(
        HttpClient httpClient,
        IOptions<GooglePlayOptions> options)
    {
        _httpClient = httpClient;
        _options = options.Value;
    }

    public async Task<VerifiedGooglePlaySubscription> VerifyAsync(
        string purchaseToken,
        CancellationToken cancellationToken = default)
    {
        if (string.IsNullOrWhiteSpace(_options.PackageName))
            throw new InvalidOperationException("GooglePlay:PackageName yapılandırılmamış.");
        if (string.IsNullOrWhiteSpace(purchaseToken))
            throw new ArgumentException("purchaseToken zorunludur.", nameof(purchaseToken));

        var accessToken = await GetAccessTokenAsync(cancellationToken);

        var url = $"{ApiBase}/androidpublisher/v3/applications/" +
                  $"{Uri.EscapeDataString(_options.PackageName)}/purchases/subscriptionsv2/" +
                  $"tokens/{Uri.EscapeDataString(purchaseToken)}";
        using var request = new HttpRequestMessage(HttpMethod.Get, url);
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", accessToken);

        using var response = await _httpClient.SendAsync(request, cancellationToken);
        var body = await response.Content.ReadAsStringAsync(cancellationToken);
        if (!response.IsSuccessStatusCode)
            throw new InvalidOperationException(
                $"Play abonelik doğrulaması başarısız ({(int)response.StatusCode}): {body}");

        return Parse(body);
    }

    private async Task<string> GetAccessTokenAsync(CancellationToken cancellationToken)
    {
        if (_credential == null)
        {
            await _credentialLock.WaitAsync(cancellationToken);
            try
            {
                _credential ??= (await GoogleCredential.GetApplicationDefaultAsync(cancellationToken))
                    .CreateScoped(Scope);
            }
            finally
            {
                _credentialLock.Release();
            }
        }

        return await _credential.GetAccessTokenForRequestAsync(cancellationToken: cancellationToken);
    }

    private static VerifiedGooglePlaySubscription Parse(string json)
    {
        using var document = JsonDocument.Parse(json);
        var root = document.RootElement;

        var state = root.TryGetProperty("subscriptionState", out var st)
            ? st.GetString() ?? string.Empty
            : string.Empty;

        string productId = string.Empty;
        DateTime? expiresAt = null;
        if (root.TryGetProperty("lineItems", out var lineItems) &&
            lineItems.ValueKind == JsonValueKind.Array)
        {
            foreach (var item in lineItems.EnumerateArray())
            {
                if (productId.Length == 0 &&
                    item.TryGetProperty("productId", out var pid))
                    productId = pid.GetString() ?? string.Empty;

                if (item.TryGetProperty("expiryTime", out var exp) &&
                    exp.TryGetDateTime(out var expValue))
                {
                    var expUtc = expValue.ToUniversalTime();
                    if (expiresAt == null || expUtc > expiresAt)
                        expiresAt = expUtc;
                }
            }
        }

        string? obfuscatedAccountId = null;
        if (root.TryGetProperty("externalAccountIdentifiers", out var ext) &&
            ext.TryGetProperty("obfuscatedExternalAccountId", out var oid))
            obfuscatedAccountId = oid.GetString();

        var latestOrderId = root.TryGetProperty("latestOrderId", out var loi)
            ? loi.GetString()
            : null;
        var linkedPurchaseToken = root.TryGetProperty("linkedPurchaseToken", out var lpt)
            ? lpt.GetString()
            : null;
        var isTest = root.TryGetProperty("testPurchase", out _);

        return new VerifiedGooglePlaySubscription(
            productId,
            expiresAt,
            state,
            obfuscatedAccountId,
            latestOrderId,
            linkedPurchaseToken,
            isTest);
    }
}
