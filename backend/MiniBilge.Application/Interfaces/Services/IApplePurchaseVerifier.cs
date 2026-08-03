namespace MiniBilge.Application.Interfaces.Services;

public interface IApplePurchaseVerifier
{
    Task<VerifiedAppleTransaction> VerifyAsync(
        string transactionId,
        CancellationToken cancellationToken = default);

    // Apple'dan webhook URL'ine imzalı bir TEST bildirimi gönderilmesini ister.
    Task<AppleTestNotificationResult> RequestTestNotificationAsync(
        CancellationToken cancellationToken = default);

    // Daha önce istenen test bildiriminin teslim durumunu (ham JSON) döner.
    Task<string> GetTestNotificationStatusAsync(
        string environment,
        string token,
        CancellationToken cancellationToken = default);
}

public sealed record AppleTestNotificationResult(string Environment, string Token);

public sealed record VerifiedAppleTransaction(
    string TransactionId,
    string OriginalTransactionId,
    string ProductId,
    string Environment,
    DateTime PurchasedAt,
    DateTime ExpiresAt,
    DateTime? RevokedAt,
    Guid? AppAccountToken);
