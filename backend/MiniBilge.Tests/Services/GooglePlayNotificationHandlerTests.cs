using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3: Google Play RTDN handler — doğrulama, idempotency, durum eşleme.
public class GooglePlayNotificationHandlerTests : IDisposable
{
    private sealed class FakeVerifier : IGooglePlayPurchaseVerifier
    {
        public VerifiedGooglePlaySubscription Result { get; set; } =
            new("minibilge_premium_monthly", DateTime.UtcNow.AddMonths(1),
                "SUBSCRIPTION_STATE_ACTIVE", null, "GPA.1", null, false);
        public int CallCount { get; private set; }

        public Task<VerifiedGooglePlaySubscription> VerifyAsync(
            string purchaseToken, CancellationToken cancellationToken = default)
        {
            CallCount++;
            return Task.FromResult(Result);
        }
    }

    private sealed class NoOpEntitlementService : IEntitlementService
    {
        public Task<EntitlementSnapshot> GetForUserAsync(
            Guid userId, CancellationToken cancellationToken = default)
            => Task.FromResult(EntitlementSnapshot.NotPremium);
        public void Invalidate(Guid userId) { }
    }

    private readonly ApplicationDbContext _context;
    private readonly FakeVerifier _verifier = new();
    private readonly GooglePlayNotificationHandler _handler;

    public GooglePlayNotificationHandlerTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _handler = new GooglePlayNotificationHandler(
            _context, _verifier, new NoOpEntitlementService());
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    private static GooglePlayDeveloperNotification SubNotification(int type, string token)
        => new()
        {
            Version = "1.0",
            PackageName = "com.minibilge.mobile",
            EventTimeMillis = "1",
            SubscriptionNotification = new GooglePlaySubscriptionNotification
            {
                Version = "1.0",
                NotificationType = type,
                PurchaseToken = token,
                SubscriptionId = "minibilge_premium_monthly",
            },
        };

    private void SetVerified(string state, DateTime? expiry, Guid? account)
        => _verifier.Result = new VerifiedGooglePlaySubscription(
            "minibilge_premium_monthly", expiry, state, account?.ToString(),
            "GPA.1", null, false);

    [Fact]
    public async Task HandleAsync_YeniSatinAlma_AbonelikVeIslemKaydiOlusturur()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", DateTime.UtcNow.AddMonths(1), userId);

        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-1");

        _context.UserSubscriptions.Count().Should().Be(1);
        _context.PurchaseTransactions.Count().Should().Be(1);
        var sub = _context.UserSubscriptions.Single();
        sub.UserId.Should().Be(userId);
        sub.Provider.Should().Be(SubscriptionProvider.GooglePlay);
        sub.Status.Should().Be(SubscriptionStatus.Active);
        sub.OriginalTransactionId.Should().Be("tok-1");
    }

    [Fact]
    public async Task HandleAsync_AyniMessageIdIkiKez_TekIslemKaydi()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", DateTime.UtcNow.AddMonths(1), userId);

        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-dup");
        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-dup");

        _context.PurchaseTransactions.Count().Should().Be(1);
        _context.UserSubscriptions.Count().Should().Be(1);
        _verifier.CallCount.Should().Be(1); // ikinci çağrı dedup ile erken döner
    }

    [Fact]
    public async Task HandleAsync_Yenileme_AboneligiGunceller_YeniAbonelikYaratmaz()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", DateTime.UtcNow.AddMonths(1), userId);
        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-1");

        var renewedExpiry = DateTime.UtcNow.AddMonths(2);
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", renewedExpiry, userId);
        await _handler.HandleAsync(SubNotification(2, "tok-1"), "msg-2");

        _context.UserSubscriptions.Count().Should().Be(1);
        _context.PurchaseTransactions.Count().Should().Be(2);
        _context.UserSubscriptions.Single().ExpiresAt
            .Should().BeCloseTo(renewedExpiry, TimeSpan.FromSeconds(1));
    }

    [Fact]
    public async Task HandleAsync_Revoked_AboneligiRevokedYapar()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", DateTime.UtcNow.AddMonths(1), userId);
        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-1");

        // notificationType 12 = REVOKED (state ACTIVE olsa bile geçersiz kılınır).
        await _handler.HandleAsync(SubNotification(12, "tok-1"), "msg-2");

        var sub = _context.UserSubscriptions.Single();
        sub.Status.Should().Be(SubscriptionStatus.Revoked);
        sub.RevokedAt.Should().NotBeNull();
    }

    [Fact]
    public async Task HandleAsync_VoidedPurchase_AboneligiRevokedYapar()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_ACTIVE", DateTime.UtcNow.AddMonths(1), userId);
        await _handler.HandleAsync(SubNotification(4, "tok-1"), "msg-1");

        var voided = new GooglePlayDeveloperNotification
        {
            VoidedPurchaseNotification = new GooglePlayVoidedPurchaseNotification
            {
                PurchaseToken = "tok-1",
                OrderId = "GPA.1",
                ProductType = 2,
                RefundType = 1,
            },
        };
        await _handler.HandleAsync(voided, "msg-2");

        _context.UserSubscriptions.Single().Status.Should().Be(SubscriptionStatus.Revoked);
    }

    [Fact]
    public async Task HandleAsync_GracePeriodDurumu_GracePeriodYapar()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
            DateTime.UtcNow.AddDays(-1), userId);

        await _handler.HandleAsync(SubNotification(6, "tok-1"), "msg-1");

        _context.UserSubscriptions.Single().Status
            .Should().Be(SubscriptionStatus.GracePeriod);
    }

    [Fact]
    public async Task HandleAsync_SuresiDolmus_ExpiredYapar()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_EXPIRED", DateTime.UtcNow.AddDays(-1), userId);

        await _handler.HandleAsync(SubNotification(13, "tok-1"), "msg-1");

        _context.UserSubscriptions.Single().Status
            .Should().Be(SubscriptionStatus.Expired);
    }

    [Fact]
    public async Task HandleAsync_IptalAmaSuresiDolmamis_ActiveTutar()
    {
        var userId = Guid.NewGuid();
        SetVerified("SUBSCRIPTION_STATE_CANCELED", DateTime.UtcNow.AddDays(10), userId);

        await _handler.HandleAsync(SubNotification(3, "tok-1"), "msg-1");

        _context.UserSubscriptions.Single().Status
            .Should().Be(SubscriptionStatus.Active);
    }

    [Fact]
    public async Task HandleAsync_TestBildirimi_YalnizIslemKaydi_AbonelikYok()
    {
        var notification = new GooglePlayDeveloperNotification
        {
            Version = "1.0",
            PackageName = "com.minibilge.mobile",
            TestNotification = new GooglePlayTestNotification { Version = "1.0" },
        };

        await _handler.HandleAsync(notification, "msg-test");

        _context.UserSubscriptions.Count().Should().Be(0);
        _context.PurchaseTransactions.Count().Should().Be(1);
        _verifier.CallCount.Should().Be(0);
    }
}
