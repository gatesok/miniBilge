using System.Security.Cryptography;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Text.Json;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// App Store Server Notification V2 (signedPayload) doğrulaması.
/// JWS header'daki x5c sertifika zinciri, pinlenmiş Apple Root CA - G3'e kadar
/// doğrulanır; ardından imza leaf sertifikanın public key'i ile (ES256) kontrol edilir.
/// Root sertifika yapılandırılmamışsa fail-closed davranır.
/// </summary>
public sealed class AppStoreNotificationVerifier : IAppStoreNotificationVerifier
{
    private readonly AppleStoreOptions _options;
    private readonly Lazy<X509Certificate2> _appleRoot;

    public AppStoreNotificationVerifier(IOptions<AppleStoreOptions> options)
    {
        _options = options.Value;
        _appleRoot = new Lazy<X509Certificate2>(LoadAppleRoot);
    }

    public AppStoreServerNotification Verify(string signedPayload)
    {
        if (string.IsNullOrWhiteSpace(signedPayload))
            throw new InvalidOperationException("signedPayload boş.");

        var payloadBytes = VerifyAndGetPayload(signedPayload);
        using var doc = JsonDocument.Parse(payloadBytes);
        var root = doc.RootElement;

        var notificationType = GetRequiredString(root, "notificationType");
        var subtype = root.TryGetProperty("subtype", out var st) ? st.GetString() : null;
        var notificationUuid = GetRequiredString(root, "notificationUUID");

        if (!root.TryGetProperty("data", out var data))
            throw new InvalidOperationException("Bildirimde data alanı yok.");

        var bundleId = GetRequiredString(data, "bundleId");
        if (!string.Equals(bundleId, _options.BundleId, StringComparison.Ordinal))
            throw new InvalidOperationException("Bildirim farklı bir uygulamaya ait.");

        var environment = data.TryGetProperty("environment", out var env)
            ? env.GetString() ?? "Production"
            : "Production";

        AppStoreTransactionInfo? transaction = null;
        if (data.TryGetProperty("signedTransactionInfo", out var sti) &&
            sti.GetString() is string signedTx &&
            !string.IsNullOrWhiteSpace(signedTx))
        {
            var txBytes = VerifyAndGetPayload(signedTx);
            using var txDoc = JsonDocument.Parse(txBytes);
            transaction = ParseTransaction(txDoc.RootElement);
        }

        return new AppStoreServerNotification(
            notificationType, subtype, notificationUuid, bundleId, environment, transaction);
    }

    // JWS'i (x5c) Apple Root CA'ya kadar doğrular, imzayı kontrol eder, payload byte'larını döner.
    private byte[] VerifyAndGetPayload(string jws)
    {
        var parts = jws.Split('.');
        if (parts.Length != 3)
            throw new InvalidOperationException("Geçersiz JWS formatı.");

        var headerBytes = Base64UrlEncoder.DecodeBytes(parts[0]);
        var payloadBytes = Base64UrlEncoder.DecodeBytes(parts[1]);
        var signature = Base64UrlEncoder.DecodeBytes(parts[2]);

        var certs = ExtractCertificates(headerBytes);
        if (certs.Count == 0)
            throw new InvalidOperationException("JWS header'da x5c yok.");

        var leaf = certs[0];
        try
        {
            VerifyChain(leaf, certs);

            using var ecdsa = leaf.GetECDsaPublicKey()
                ?? throw new InvalidOperationException("Leaf sertifikada ECDSA public key yok.");
            var signingInput = Encoding.ASCII.GetBytes($"{parts[0]}.{parts[1]}");
            var valid = ecdsa.VerifyData(
                signingInput, signature,
                HashAlgorithmName.SHA256,
                DSASignatureFormat.IeeeP1363FixedFieldConcatenation);
            if (!valid)
                throw new InvalidOperationException("JWS imzası geçersiz.");

            return payloadBytes;
        }
        finally
        {
            foreach (var cert in certs)
                cert.Dispose();
        }
    }

    private void VerifyChain(X509Certificate2 leaf, List<X509Certificate2> certs)
    {
        var appleRoot = _appleRoot.Value;
        using var chain = new X509Chain();
        chain.ChainPolicy.RevocationMode = X509RevocationMode.NoCheck;
        chain.ChainPolicy.TrustMode = X509ChainTrustMode.CustomRootTrust;
        chain.ChainPolicy.CustomTrustStore.Add(appleRoot);
        for (var i = 1; i < certs.Count; i++)
            chain.ChainPolicy.ExtraStore.Add(certs[i]);

        if (!chain.Build(leaf))
        {
            var errors = string.Join(
                ", ", chain.ChainStatus.Select(s => s.StatusInformation.Trim()));
            throw new InvalidOperationException($"Sertifika zinciri doğrulanamadı. {errors}");
        }

        // Zincirin gerçekten pinlenmiş Apple Root'a bağlandığını doğrula.
        var chainRoot = chain.ChainElements[^1].Certificate;
        if (!chainRoot.RawData.AsSpan().SequenceEqual(appleRoot.RawData))
            throw new InvalidOperationException("Zincir kökü Apple Root CA ile eşleşmiyor.");
    }

    private static List<X509Certificate2> ExtractCertificates(byte[] headerBytes)
    {
        using var headerDoc = JsonDocument.Parse(headerBytes);
        if (!headerDoc.RootElement.TryGetProperty("x5c", out var x5c) ||
            x5c.ValueKind != JsonValueKind.Array)
            return new List<X509Certificate2>();

        var certs = new List<X509Certificate2>();
        foreach (var entry in x5c.EnumerateArray())
        {
            var raw = entry.GetString();
            if (string.IsNullOrWhiteSpace(raw))
                continue;
            certs.Add(X509CertificateLoader.LoadCertificate(Convert.FromBase64String(raw)));
        }
        return certs;
    }

    private X509Certificate2 LoadAppleRoot()
    {
        if (string.IsNullOrWhiteSpace(_options.RootCertificateBase64))
            throw new InvalidOperationException(
                "Apple Root CA yapılandırılmamış (AppleStore:RootCertificateBase64). " +
                "Webhook doğrulaması devre dışı.");
        return X509CertificateLoader.LoadCertificate(
            Convert.FromBase64String(_options.RootCertificateBase64.Trim()));
    }

    private static AppStoreTransactionInfo ParseTransaction(JsonElement root)
    {
        Guid? appAccountToken = null;
        if (root.TryGetProperty("appAccountToken", out var accountElement) &&
            Guid.TryParse(accountElement.GetString(), out var parsedToken))
            appAccountToken = parsedToken;

        return new AppStoreTransactionInfo(
            GetRequiredString(root, "transactionId"),
            GetRequiredString(root, "originalTransactionId"),
            GetRequiredString(root, "productId"),
            FromUnixMilliseconds(root, "purchaseDate") ?? DateTime.UnixEpoch,
            FromUnixMilliseconds(root, "expiresDate"),
            FromUnixMilliseconds(root, "revocationDate"),
            appAccountToken);
    }

    private static string GetRequiredString(JsonElement root, string property)
    {
        if (!root.TryGetProperty(property, out var value) ||
            string.IsNullOrWhiteSpace(value.GetString()))
            throw new InvalidOperationException($"Bildirimde {property} eksik.");
        return value.GetString()!;
    }

    private static DateTime? FromUnixMilliseconds(JsonElement root, string property)
    {
        return root.TryGetProperty(property, out var value) &&
               value.TryGetInt64(out var milliseconds)
            ? DateTimeOffset.FromUnixTimeMilliseconds(milliseconds).UtcDateTime
            : null;
    }
}
