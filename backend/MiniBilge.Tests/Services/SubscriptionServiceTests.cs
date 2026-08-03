using FluentAssertions;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3-T01: Entitlement ("premium sayılır") kuralının birim testleri.
public class SubscriptionServiceTests
{
    private readonly SubscriptionService _service = new();
    private readonly DateTime _now = new(2026, 8, 3, 12, 0, 0, DateTimeKind.Utc);

    private UserSubscription Sub(
        SubscriptionStatus status,
        DateTime expiresAt,
        bool isDeleted = false)
        => new()
        {
            Id = Guid.NewGuid(),
            UserId = Guid.NewGuid(),
            Provider = SubscriptionProvider.Apple,
            Status = status,
            ExpiresAt = expiresAt,
            IsDeleted = isDeleted,
        };

    [Theory]
    [InlineData(SubscriptionStatus.Active)]
    [InlineData(SubscriptionStatus.GracePeriod)]
    public void IsPremium_AktifVeyaGrace_SuresiDolmamis_True(SubscriptionStatus status)
    {
        var subs = new[] { Sub(status, _now.AddDays(5)) };

        _service.IsPremium(subs, _now).Should().BeTrue();
    }

    [Fact]
    public void IsPremium_AktifAmaSuresiDolmus_False()
    {
        var subs = new[] { Sub(SubscriptionStatus.Active, _now.AddDays(-1)) };

        _service.IsPremium(subs, _now).Should().BeFalse();
    }

    [Theory]
    [InlineData(SubscriptionStatus.Expired)]
    [InlineData(SubscriptionStatus.Revoked)]
    [InlineData(SubscriptionStatus.Pending)]
    public void IsPremium_AktifOlmayanStatus_False(SubscriptionStatus status)
    {
        var subs = new[] { Sub(status, _now.AddDays(5)) };

        _service.IsPremium(subs, _now).Should().BeFalse();
    }

    [Fact]
    public void IsPremium_SilinmisAbonelik_False()
    {
        var subs = new[] { Sub(SubscriptionStatus.Active, _now.AddDays(5), isDeleted: true) };

        _service.IsPremium(subs, _now).Should().BeFalse();
    }

    [Fact]
    public void IsPremium_BosListe_False()
    {
        _service.IsPremium(Array.Empty<UserSubscription>(), _now).Should().BeFalse();
    }

    [Fact]
    public void GetActiveSubscription_BirdenFazlaAktif_EnGecBiteniSecer()
    {
        var near = Sub(SubscriptionStatus.Active, _now.AddDays(3));
        var far = Sub(SubscriptionStatus.Active, _now.AddDays(30));
        var subs = new[] { near, far };

        var result = _service.GetActiveSubscription(subs, _now);

        result.Should().Be(far);
    }

    [Fact]
    public void GetActiveSubscription_KarisikListe_YalnizGecerliyiSecer()
    {
        var expired = Sub(SubscriptionStatus.Expired, _now.AddDays(10));
        var revoked = Sub(SubscriptionStatus.Revoked, _now.AddDays(10));
        var active = Sub(SubscriptionStatus.Active, _now.AddDays(2));
        var subs = new[] { expired, revoked, active };

        _service.GetActiveSubscription(subs, _now).Should().Be(active);
    }
}
