namespace MiniBilge.Application.DTOs.Premium;

public sealed class VerifyApplePurchaseRequest
{
    public string TransactionId { get; set; } = string.Empty;
    public string ProductId { get; set; } = string.Empty;
}
