using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Infrastructure.Options;

namespace MiniBilge.Infrastructure.Services;

public sealed class ExternalTokenProtector : IExternalTokenProtector
{
    private static readonly byte[] AdditionalData =
        Encoding.UTF8.GetBytes("MiniBilge.ExternalProviderToken.v1");

    private readonly string _configuredKey;

    public ExternalTokenProtector(IOptions<AppleSignInOptions> options)
    {
        _configuredKey = options.Value.TokenEncryptionKey;
    }

    public string Protect(string plaintext)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(plaintext);

        var nonce = RandomNumberGenerator.GetBytes(12);
        var plaintextBytes = Encoding.UTF8.GetBytes(plaintext);
        var ciphertext = new byte[plaintextBytes.Length];
        var tag = new byte[16];

        using var aes = new AesGcm(GetKey(), tag.Length);
        aes.Encrypt(
            nonce,
            plaintextBytes,
            ciphertext,
            tag,
            AdditionalData);

        var payload = new byte[nonce.Length + tag.Length + ciphertext.Length];
        Buffer.BlockCopy(nonce, 0, payload, 0, nonce.Length);
        Buffer.BlockCopy(tag, 0, payload, nonce.Length, tag.Length);
        Buffer.BlockCopy(
            ciphertext,
            0,
            payload,
            nonce.Length + tag.Length,
            ciphertext.Length);

        return Convert.ToBase64String(payload);
    }

    public string Unprotect(string protectedValue)
    {
        ArgumentException.ThrowIfNullOrWhiteSpace(protectedValue);

        byte[] payload;
        try
        {
            payload = Convert.FromBase64String(protectedValue);
        }
        catch (FormatException)
        {
            throw new InvalidOperationException(
                "Saklanan sağlayıcı tokenı çözümlenemedi");
        }

        if (payload.Length <= 28)
        {
            throw new InvalidOperationException(
                "Saklanan sağlayıcı tokenı geçersiz");
        }

        var nonce = payload.AsSpan(0, 12);
        var tag = payload.AsSpan(12, 16);
        var ciphertext = payload.AsSpan(28);
        var plaintext = new byte[ciphertext.Length];

        try
        {
            using var aes = new AesGcm(GetKey(), tag.Length);
            aes.Decrypt(
                nonce,
                ciphertext,
                tag,
                plaintext,
                AdditionalData);
        }
        catch (CryptographicException)
        {
            throw new InvalidOperationException(
                "Saklanan sağlayıcı tokenı çözümlenemedi");
        }

        return Encoding.UTF8.GetString(plaintext);
    }

    private byte[] GetKey()
    {
        byte[] key;
        try
        {
            key = Convert.FromBase64String(_configuredKey);
        }
        catch (FormatException)
        {
            throw new InvalidOperationException(
                "Apple token şifreleme anahtarı geçerli Base64 formatında değil");
        }

        if (key.Length != 32)
        {
            throw new InvalidOperationException(
                "Apple token şifreleme anahtarı 32 byte olmalıdır");
        }

        return key;
    }
}
