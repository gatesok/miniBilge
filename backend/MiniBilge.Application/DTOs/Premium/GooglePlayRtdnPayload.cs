using System.Text.Json.Serialization;

namespace MiniBilge.Application.DTOs.Premium;

/// <summary>
/// Pub/Sub push zarfı: RTDN mesajı bu gövdeyle Cloud Run'a POST edilir.
/// </summary>
public sealed class GooglePlayRtdnPayload
{
    [JsonPropertyName("message")]
    public GooglePlayPubSubMessage? Message { get; set; }

    [JsonPropertyName("subscription")]
    public string? Subscription { get; set; }
}

public sealed class GooglePlayPubSubMessage
{
    // Base64 kodlanmış DeveloperNotification JSON'u.
    [JsonPropertyName("data")]
    public string? Data { get; set; }

    [JsonPropertyName("messageId")]
    public string? MessageId { get; set; }

    [JsonPropertyName("publishTime")]
    public string? PublishTime { get; set; }
}

/// <summary>
/// Base64 çözülüp elde edilen Google Play Developer Notification.
/// </summary>
public sealed class GooglePlayDeveloperNotification
{
    [JsonPropertyName("version")]
    public string? Version { get; set; }

    [JsonPropertyName("packageName")]
    public string? PackageName { get; set; }

    [JsonPropertyName("eventTimeMillis")]
    public string? EventTimeMillis { get; set; }

    [JsonPropertyName("subscriptionNotification")]
    public GooglePlaySubscriptionNotification? SubscriptionNotification { get; set; }

    [JsonPropertyName("oneTimeProductNotification")]
    public GooglePlayOneTimeProductNotification? OneTimeProductNotification { get; set; }

    [JsonPropertyName("voidedPurchaseNotification")]
    public GooglePlayVoidedPurchaseNotification? VoidedPurchaseNotification { get; set; }

    [JsonPropertyName("testNotification")]
    public GooglePlayTestNotification? TestNotification { get; set; }
}

public sealed class GooglePlaySubscriptionNotification
{
    [JsonPropertyName("version")]
    public string? Version { get; set; }

    // 1=RECOVERED 2=RENEWED 3=CANCELED 4=PURCHASED 5=ON_HOLD 6=IN_GRACE_PERIOD
    // 7=RESTARTED 8=PRICE_CHANGE_CONFIRMED 9=DEFERRED 10=PAUSED
    // 11=PAUSE_SCHEDULE_CHANGED 12=REVOKED 13=EXPIRED
    [JsonPropertyName("notificationType")]
    public int NotificationType { get; set; }

    [JsonPropertyName("purchaseToken")]
    public string? PurchaseToken { get; set; }

    [JsonPropertyName("subscriptionId")]
    public string? SubscriptionId { get; set; }
}

public sealed class GooglePlayOneTimeProductNotification
{
    [JsonPropertyName("notificationType")]
    public int NotificationType { get; set; }

    [JsonPropertyName("purchaseToken")]
    public string? PurchaseToken { get; set; }

    [JsonPropertyName("sku")]
    public string? Sku { get; set; }
}

public sealed class GooglePlayVoidedPurchaseNotification
{
    [JsonPropertyName("purchaseToken")]
    public string? PurchaseToken { get; set; }

    [JsonPropertyName("orderId")]
    public string? OrderId { get; set; }

    // 1=ONE_TIME 2=SUBSCRIPTION
    [JsonPropertyName("productType")]
    public int ProductType { get; set; }

    // 1=REFUND 2=CHARGEBACK
    [JsonPropertyName("refundType")]
    public int RefundType { get; set; }
}

public sealed class GooglePlayTestNotification
{
    [JsonPropertyName("version")]
    public string? Version { get; set; }
}
