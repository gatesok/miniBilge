using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Options;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Xunit;

namespace MiniBilge.Tests.Services;

// P3-S04: Abonelik sahibi parent/user hesabı; yararlanıcı child profilleridir.
// Çocuğun premium durumu, ait olduğu parent user'ın aboneliğinden türetilir.
public class SubscriptionOwnershipTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly DailyUsageService _service;

    public SubscriptionOwnershipTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);
        _service = new DailyUsageService(
            _context,
            Options.Create(new DailyUsageOptions()),
            new SubscriptionService());
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    // Bir parent user + altında bir çocuk profili oluşturur. Abonelik verilirse aktif eklenir.
    private (Guid userId, Guid childId) SeedFamily(bool premium)
    {
        var userId = Guid.NewGuid();
        var parentProfileId = Guid.NewGuid();
        var childId = Guid.NewGuid();

        var user = new User
        {
            Id = userId,
            Email = $"{userId}@test.local",
            Role = UserRole.Parent,
        };
        var parentProfile = new ParentProfile
        {
            Id = parentProfileId,
            UserId = userId,
            User = user,
        };
        var child = new ChildProfile
        {
            Id = childId,
            ParentProfileId = parentProfileId,
            ParentProfile = parentProfile,
            Name = "Çocuk",
        };

        if (premium)
        {
            user.Subscriptions.Add(new UserSubscription
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Provider = SubscriptionProvider.Apple,
                Status = SubscriptionStatus.Active,
                ExpiresAt = DateTime.UtcNow.AddMonths(1),
                CreatedAt = DateTime.UtcNow,
            });
        }

        _context.Users.Add(user);
        _context.ParentProfiles.Add(parentProfile);
        _context.ChildProfiles.Add(child);
        _context.SaveChanges();
        return (userId, childId);
    }

    [Fact]
    public async Task PremiumParent_CocukPremiumHaklariMirasAlir()
    {
        var (userId, childId) = SeedFamily(premium: true);

        var status = await _service.GetStatusAsync(userId, childId, "adaptive_quiz");

        status.IsPremium.Should().BeTrue();
        status.BaseLimit.Should().Be(10); // premium limit
    }

    [Fact]
    public async Task UcretsizParent_CocukUcretsizLimiteSahip()
    {
        var (userId, childId) = SeedFamily(premium: false);

        var status = await _service.GetStatusAsync(userId, childId, "adaptive_quiz");

        status.IsPremium.Should().BeFalse();
        status.BaseLimit.Should().Be(1); // free limit
    }

    [Fact]
    public async Task BaskaHesabinCocugu_PremiumMirasAlmaz()
    {
        SeedFamily(premium: true);
        var (otherUserId, otherChildId) = SeedFamily(premium: false);

        var status = await _service.GetStatusAsync(otherUserId, otherChildId, "adaptive_quiz");

        status.IsPremium.Should().BeFalse();
    }

    [Fact]
    public async Task BaskaKullanicininCocugunaErisim_Reddedilir()
    {
        SeedFamily(premium: true);
        var (_, foreignChildId) = SeedFamily(premium: false);
        var (attackerUserId, _) = SeedFamily(premium: true);

        var act = async () =>
            await _service.GetStatusAsync(attackerUserId, foreignChildId, "adaptive_quiz");

        await act.Should().ThrowAsync<UnauthorizedAccessException>();
    }
}
