using System.Net;
using System.Security.Cryptography;
using System.Text;
using FluentAssertions;
using Microsoft.Extensions.Options;
using MiniBilge.Infrastructure.Options;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.Tests.Services;

public sealed class AppleTokenServiceTests
{
    [Fact]
    public async Task ExchangeAuthorizationCodeAsync_CalledRepeatedly_DoesNotReuseDisposedKey()
    {
        using var ecdsa = ECDsa.Create(ECCurve.NamedCurves.nistP256);
        using var httpClient = new HttpClient(new AppleTokenHandler());
        var service = new AppleTokenService(
            httpClient,
            Options.Create(
                new AppleSignInOptions
                {
                    ClientId = "com.minibilge.mobile",
                    TeamId = "TEAMID1234",
                    KeyId = "KEYID12345",
                    PrivateKey = ecdsa.ExportPkcs8PrivateKeyPem()
                }));

        var first = await service.ExchangeAuthorizationCodeAsync("first-code");
        var second = await service.ExchangeAuthorizationCodeAsync("second-code");

        first.AccessToken.Should().Be("apple-access-token");
        second.AccessToken.Should().Be("apple-access-token");
    }

    private sealed class AppleTokenHandler : HttpMessageHandler
    {
        protected override Task<HttpResponseMessage> SendAsync(
            HttpRequestMessage request,
            CancellationToken cancellationToken)
        {
            const string response = """
            {
              "access_token": "apple-access-token",
              "refresh_token": "apple-refresh-token",
              "expires_in": 3600
            }
            """;

            return Task.FromResult(
                new HttpResponseMessage(HttpStatusCode.OK)
                {
                    Content = new StringContent(
                        response,
                        Encoding.UTF8,
                        "application/json")
                });
        }
    }
}
