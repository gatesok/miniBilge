namespace MiniBilge.Application.Interfaces.Services;

public interface IApplePurchaseVerifier
{
    Task<VerifiedAppleTransaction> VerifyAsync(
        string transactionId,
        CancellationToken cancellationToken = default);
}

public sealed record VerifiedAppleTransaction(
    string TransactionId,
    string OriginalTransactionId,
    string ProductId,
    string Environment,
    DateTime PurchasedAt,
    DateTime ExpiresAt,
    DateTime? RevokedAt,
    Guid? AppAccountToken);
