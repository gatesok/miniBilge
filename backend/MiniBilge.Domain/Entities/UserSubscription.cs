using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class UserSubscription : BaseEntity
{
    public Guid UserId { get; set; }
    public SubscriptionProvider Provider { get; set; }
    public SubscriptionStatus Status { get; set; } = SubscriptionStatus.Pending;
    public string ProductId { get; set; } = string.Empty;
    public string OriginalTransactionId { get; set; } = string.Empty;
    public string Environment { get; set; } = "Production";
    public DateTime PurchasedAt { get; set; }
    public DateTime ExpiresAt { get; set; }
    public DateTime? RevokedAt { get; set; }
    public DateTime LastVerifiedAt { get; set; }

    public User User { get; set; } = null!;
}
