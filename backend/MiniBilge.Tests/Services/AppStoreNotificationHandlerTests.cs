using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3-S03: App Store server notification replay/duplicate koruması.
public class AppStoreNotificationHandlerTests : IDisposable
{
    // Handler testlerinde cache invalidation önemsiz; no-op yeterli.
    private sealed class NoOpEntitlementService : IEntitlementService
    {
        public Task<EntitlementSnapshot> GetForUserAsync(
            Guid userId, CancellationToken cancellationToken = default)
            => Task.FromResult(EntitlementSnapshot.NotPremium);

        public void Invalidate(Guid userId) { }
    }
    private readonly ApplicationDbContext _context;
    private readonly AppStoreNotificationHandler _handler;

    public AppStoreNotificationHandlerTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _handler = new AppStoreNotificationHandler(_context, new NoOpEntitlementService());
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private static AppStoreServerNotification BuildNotification(
        string notificationUuid,
        string originalTransactionId,
        Guid appAccountToken,
        string type = "SUBSCRIBED",
        string? subtype = null,
        DateTime? expiresAt = null,
        DateTime? revokedAt = null)
    {
        var now = DateTime.UtcNow;
        return new AppStoreServerNotification(
            NotificationType: type,
            Subtype: subtype,
            NotificationUuid: notificationUuid,
            BundleId: "com.minibilge.mobile",
            Environment: "Production",
            Transaction: new AppStoreTransactionInfo(
                TransactionId: Guid.NewGuid().ToString(),
                OriginalTransactionId: originalTransactionId,
                ProductId: "minibilge_premium_monthly",
                PurchasedAt: now,
                ExpiresAt: expiresAt ?? now.AddMonths(1),
                RevokedAt: revokedAt,
                AppAccountToken: appAccountToken));
    }

    [Fact]
    public async Task HandleAsync_YeniBildirim_AbonelikVeIslemKaydiOlusturur()
    {
        var userId = Guid.NewGuid();
        var notification = BuildNotification(
            "uuid-1", "orig-1", userId);

        await _handler.HandleAsync(notification);

        _context.UserSubscriptions.Count().Should().Be(1);
        _context.PurchaseTransactions.Count().Should().Be(1);
        var subscription = _context.UserSubscriptions.Single();
        subscription.UserId.Should().Be(userId);
        subscription.Status.Should().Be(SubscriptionStatus.Active);
        subscription.OriginalTransactionId.Should().Be("orig-1");
    }

    [Fact]
    public async Task HandleAsync_AyniNotificationUuidIkiKez_TekIslemKaydiOlusur()
    {
        var userId = Guid.NewGuid();
        var notification = BuildNotification(
            "uuid-dup", "orig-1", userId);

        await _handler.HandleAsync(notification);
        // Aynı bildirim tekrar gelir (Apple retry / çift teslim).
        await _handler.HandleAsync(notification);

        _context.PurchaseTransactions.Count().Should().Be(1);
        _context.UserSubscriptions.Count().Should().Be(1);
    }

    [Fact]
    public async Task HandleAsync_AyniAbonelikFarkliBildirim_AboneligiGunceller_YeniAbonelikYaratmaz()
    {
        var userId = Guid.NewGuid();
        var first = BuildNotification(
            "uuid-1", "orig-1", userId,
            expiresAt: DateTime.UtcNow.AddMonths(1));
        await _handler.HandleAsync(first);

        // Yenileme: aynı OriginalTransactionId, farklı notificationUUID, ileri süre.
        var renewedExpiry = DateTime.UtcNow.AddMonths(2);
        var renewal = BuildNotification(
            "uuid-2", "orig-1", userId,
            type: "DID_RENEW",
            expiresAt: renewedExpiry);
        await _handler.HandleAsync(renewal);

        _context.UserSubscriptions.Count().Should().Be(1);
        _context.PurchaseTransactions.Count().Should().Be(2);
        var subscription = _context.UserSubscriptions.Single();
        subscription.ExpiresAt.Should().BeCloseTo(renewedExpiry, TimeSpan.FromSeconds(1));
        subscription.Status.Should().Be(SubscriptionStatus.Active);
    }

    [Fact]
    public async Task HandleAsync_RefundBildirimi_AboneligiRevokedYapar()
    {
        var userId = Guid.NewGuid();
        var purchase = BuildNotification("uuid-1", "orig-1", userId);
        await _handler.HandleAsync(purchase);

        var refund = BuildNotification(
            "uuid-refund", "orig-1", userId,
            type: "REFUND",
            revokedAt: DateTime.UtcNow);
        await _handler.HandleAsync(refund);

        var subscription = _context.UserSubscriptions.Single();
        subscription.Status.Should().Be(SubscriptionStatus.Revoked);
        subscription.RevokedAt.Should().NotBeNull();
    }

    // P3-T03: Süre dolumu → Expired.
    [Fact]
    public async Task HandleAsync_SuresiGecmisBildirim_AboneligiExpiredYapar()
    {
        var userId = Guid.NewGuid();
        await _handler.HandleAsync(BuildNotification("uuid-1", "orig-1", userId));

        var expired = BuildNotification(
            "uuid-expired", "orig-1", userId,
            type: "EXPIRED",
            subtype: "VOLUNTARY",
            expiresAt: DateTime.UtcNow.AddDays(-1));
        await _handler.HandleAsync(expired);

        var subscription = _context.UserSubscriptions.Single();
        subscription.Status.Should().Be(SubscriptionStatus.Expired);
    }

    // P3-T03: Ödeme sorunu → grace period boyunca premium korunur.
    [Fact]
    public async Task HandleAsync_GracePeriodBildirimi_AboneligiGracePeriodYapar()
    {
        var userId = Guid.NewGuid();
        await _handler.HandleAsync(BuildNotification("uuid-1", "orig-1", userId));

        var grace = BuildNotification(
            "uuid-grace", "orig-1", userId,
            type: "DID_FAIL_TO_RENEW",
            subtype: "GRACE_PERIOD",
            expiresAt: DateTime.UtcNow.AddDays(-1));
        await _handler.HandleAsync(grace);

        var subscription = _context.UserSubscriptions.Single();
        subscription.Status.Should().Be(SubscriptionStatus.GracePeriod);
    }

    // P3-T03: İptal (otomatik yenileme kapatıldı) → süre sonuna kadar Active kalır.
    [Fact]
    public async Task HandleAsync_IptalAmaSuresiDolmamis_AboneligiActiveTutar()
    {
        var userId = Guid.NewGuid();
        await _handler.HandleAsync(BuildNotification("uuid-1", "orig-1", userId));

        var cancel = BuildNotification(
            "uuid-cancel", "orig-1", userId,
            type: "DID_CHANGE_RENEWAL_STATUS",
            subtype: "AUTO_RENEW_DISABLED",
            expiresAt: DateTime.UtcNow.AddDays(10));
        await _handler.HandleAsync(cancel);

        var subscription = _context.UserSubscriptions.Single();
        subscription.Status.Should().Be(SubscriptionStatus.Active);
    }
}
