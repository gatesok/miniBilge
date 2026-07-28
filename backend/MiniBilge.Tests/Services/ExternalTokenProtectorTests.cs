using System.Security.Cryptography;
using FluentAssertions;
using Microsoft.Extensions.Options;
using MiniBilge.Infrastructure.Options;
using MiniBilge.Infrastructure.Services;

namespace MiniBilge.Tests.Services;

public class ExternalTokenProtectorTests
{
    [Fact]
    public void ProtectAndUnprotect_RoundTripsToken()
    {
        var protector = CreateProtector();

        var protectedValue = protector.Protect("apple-refresh-token");

        protectedValue.Should().NotContain("apple-refresh-token");
        protector.Unprotect(protectedValue).Should().Be("apple-refresh-token");
    }

    [Fact]
    public void Protect_UsesUniqueNonce()
    {
        var protector = CreateProtector();

        var first = protector.Protect("same-token");
        var second = protector.Protect("same-token");

        first.Should().NotBe(second);
    }

    [Fact]
    public void Unprotect_RejectsTamperedPayload()
    {
        var protector = CreateProtector();
        var payload = Convert.FromBase64String(protector.Protect("token"));
        payload[^1] ^= 0x01;

        var action = () => protector.Unprotect(Convert.ToBase64String(payload));

        action.Should()
            .Throw<InvalidOperationException>()
            .WithMessage("Saklanan sağlayıcı tokenı çözümlenemedi");
    }

    private static ExternalTokenProtector CreateProtector()
    {
        return new ExternalTokenProtector(
            Options.Create(
                new AppleSignInOptions
                {
                    TokenEncryptionKey = Convert.ToBase64String(
                        RandomNumberGenerator.GetBytes(32))
                }));
    }
}
