using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Mağaza satın alma/abonelik olaylarının denetim izi ve idempotency kaydı.
/// Hem client doğrulama (verify) hem de server bildirimleri (webhook) buraya yazar.
/// (Provider, DedupKey) benzersizdir → aynı olay iki kez işlenmez.
/// </summary>
public class PurchaseTransaction : BaseEntity
{
    public Guid? UserId { get; set; }
    public SubscriptionProvider Provider { get; set; }

    // Idempotency anahtarı: webhook için notificationUUID, verify için transaction/dönem anahtarı.
    public string DedupKey { get; set; } = string.Empty;

    // client_verify | app_store_notification | play_rtdn
    public string Source { get; set; } = string.Empty;

    public string? NotificationType { get; set; }
    public string? OriginalTransactionId { get; set; }
    public string? TransactionId { get; set; }
    public string? ProductId { get; set; }
    public string? Environment { get; set; }
    public SubscriptionStatus? Status { get; set; }
    public DateTime? PurchasedAt { get; set; }
    public DateTime? ExpiresAt { get; set; }
    public string? RawPayload { get; set; }
    public DateTime? ProcessedAt { get; set; }

    public User? User { get; set; }
}
