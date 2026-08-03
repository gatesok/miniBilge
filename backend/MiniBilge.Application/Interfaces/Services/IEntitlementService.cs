using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Services;

/// <summary>
/// Kullanıcı entitlement (premium) durumunu kısa süreli cache'ler ve DB erişimi
/// başarısız olduğunda güvenli fallback davranışı sağlar.
/// </summary>
public interface IEntitlementService
{
    /// <summary>
    /// Kullanıcının güncel entitlement özetini döner. Önce cache; cache yoksa DB.
    /// DB erişimi başarısızsa son bilinen değere (varsa) düşer, yoksa premium-değil döner.
    /// </summary>
    Task<EntitlementSnapshot> GetForUserAsync(
        Guid userId, CancellationToken cancellationToken = default);

    /// <summary>Kullanıcının taze cache girişini geçersiz kılar (satın alma/webhook sonrası).</summary>
    void Invalidate(Guid userId);
}

public sealed record EntitlementSnapshot(
    bool IsPremium, string? ProductId, DateTime? ExpiresAt)
{
    public static readonly EntitlementSnapshot NotPremium = new(false, null, null);

    public static EntitlementSnapshot From(UserSubscription? active) =>
        active is null
            ? NotPremium
            : new EntitlementSnapshot(true, active.ProductId, active.ExpiresAt);
}
