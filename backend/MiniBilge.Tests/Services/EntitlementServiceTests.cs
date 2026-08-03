using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Logging.Abstractions;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3-B11: Entitlement cache + güvenli fallback.
public class EntitlementServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly IMemoryCache _cache;
    private readonly EntitlementService _service;

    public EntitlementServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _cache = new MemoryCache(new MemoryCacheOptions());
        _service = new EntitlementService(
            _context,
            new SubscriptionService(),
            _cache,
            NullLogger<EntitlementService>.Instance);
    }

    public void Dispose()
    {
        try
        {
            _context.Database.EnsureDeleted();
            _context.Dispose();
        }
        catch (ObjectDisposedException)
        {
            // Bazı testler DB hatasını simüle etmek için context'i erkenden kapatır.
        }
        _cache.Dispose();
    }

    private void SeedActiveSubscription(Guid userId)
    {
        _context.UserSubscriptions.Add(new UserSubscription
        {
            Id = Guid.NewGuid(),
            UserId = userId,
            Provider = SubscriptionProvider.Apple,
            Status = SubscriptionStatus.Active,
            ProductId = "minibilge_premium_monthly",
            ExpiresAt = DateTime.UtcNow.AddMonths(1),
            CreatedAt = DateTime.UtcNow,
        });
        _context.SaveChanges();
    }

    [Fact]
    public async Task GetForUserAsync_AktifAbonelik_PremiumDoner()
    {
        var userId = Guid.NewGuid();
        SeedActiveSubscription(userId);

        var result = await _service.GetForUserAsync(userId);

        result.IsPremium.Should().BeTrue();
        result.ProductId.Should().Be("minibilge_premium_monthly");
    }

    [Fact]
    public async Task GetForUserAsync_AbonelikYok_PremiumDegil()
    {
        var result = await _service.GetForUserAsync(Guid.NewGuid());

        result.IsPremium.Should().BeFalse();
    }

    [Fact]
    public async Task GetForUserAsync_IkinciCagri_CachedDeger_DBDegisiminiGormez()
    {
        var userId = Guid.NewGuid();
        SeedActiveSubscription(userId);

        var first = await _service.GetForUserAsync(userId);
        first.IsPremium.Should().BeTrue();

        // Abonelik silinir ama cache invalidate edilmez → taze cache hâlâ premium döner.
        _context.UserSubscriptions.RemoveRange(_context.UserSubscriptions);
        await _context.SaveChangesAsync();

        var cached = await _service.GetForUserAsync(userId);
        cached.IsPremium.Should().BeTrue();
    }

    [Fact]
    public async Task Invalidate_SonrasiTazeSorgu_GuncelDegeriGetirir()
    {
        var userId = Guid.NewGuid();
        SeedActiveSubscription(userId);
        await _service.GetForUserAsync(userId);

        _context.UserSubscriptions.RemoveRange(_context.UserSubscriptions);
        await _context.SaveChangesAsync();
        _service.Invalidate(userId);

        var refreshed = await _service.GetForUserAsync(userId);
        refreshed.IsPremium.Should().BeFalse();
    }

    [Fact]
    public async Task GetForUserAsync_DBHatasi_SonBilinenDegereDuser()
    {
        var userId = Guid.NewGuid();
        SeedActiveSubscription(userId);
        await _service.GetForUserAsync(userId); // last-known-good = premium

        _service.Invalidate(userId);   // taze giriş silinir, LKG korunur
        _context.Dispose();            // sonraki DB sorgusu hata fırlatır

        var result = await _service.GetForUserAsync(userId);

        result.IsPremium.Should().BeTrue(); // fail-open: ödeme yapan kullanıcı korunur
    }

    [Fact]
    public async Task GetForUserAsync_DBHatasi_LKGYok_PremiumDegil()
    {
        var userId = Guid.NewGuid();
        _context.Dispose(); // hiç başarılı sorgu olmadan DB hatası

        var result = await _service.GetForUserAsync(userId);

        result.IsPremium.Should().BeFalse(); // fail-closed
    }
}
