using System.Security.Claims;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.API.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public sealed class PremiumController : ControllerBase
{
    private readonly ApplicationDbContext _dbContext;
    private readonly IApplePurchaseVerifier _appleVerifier;

    public PremiumController(
        ApplicationDbContext dbContext,
        IApplePurchaseVerifier appleVerifier)
    {
        _dbContext = dbContext;
        _appleVerifier = appleVerifier;
    }

    [HttpGet("status")]
    public async Task<ActionResult<PremiumStatusDto>> GetStatus(
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var subscription = await _dbContext.UserSubscriptions
            .AsNoTracking()
            .Where(x =>
                x.UserId == userId &&
                !x.IsDeleted &&
                (x.Status == SubscriptionStatus.Active ||
                 x.Status == SubscriptionStatus.GracePeriod) &&
                x.ExpiresAt > DateTime.UtcNow)
            .OrderByDescending(x => x.ExpiresAt)
            .FirstOrDefaultAsync(cancellationToken);

        return Ok(new PremiumStatusDto
        {
            IsPremium = subscription != null,
            ProductId = subscription?.ProductId,
            ExpiresAt = subscription?.ExpiresAt,
        });
    }

    [HttpPost("verify")]
    public async Task<ActionResult<PremiumStatusDto>> Verify(
        [FromBody] VerifyApplePurchaseRequest request,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(request.TransactionId))
            return BadRequest(new { message = "İşlem kimliği zorunludur." });

        var userId = GetUserId();
        var transaction = await _appleVerifier.VerifyAsync(
            request.TransactionId.Trim(), cancellationToken);

        if (!string.IsNullOrWhiteSpace(request.ProductId) &&
            !string.Equals(
                request.ProductId, transaction.ProductId, StringComparison.Ordinal))
            return BadRequest(new { message = "Ürün bilgisi Apple işlemiyle eşleşmiyor." });

        if (transaction.AppAccountToken.HasValue &&
            transaction.AppAccountToken.Value != userId)
            return Conflict(new
            {
                message = "Bu satın alma farklı bir MiniBilge hesabına ait.",
            });

        var subscription = await _dbContext.UserSubscriptions
            .SingleOrDefaultAsync(
                x => x.Provider == SubscriptionProvider.Apple &&
                     x.OriginalTransactionId == transaction.OriginalTransactionId,
                cancellationToken);

        if (subscription != null && subscription.UserId != userId)
            return Conflict(new
            {
                message = "Bu abonelik başka bir MiniBilge hesabına bağlı.",
            });

        var status = transaction.RevokedAt.HasValue
            ? SubscriptionStatus.Revoked
            : transaction.ExpiresAt > DateTime.UtcNow
                ? SubscriptionStatus.Active
                : SubscriptionStatus.Expired;

        if (subscription == null)
        {
            subscription = new UserSubscription
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Provider = SubscriptionProvider.Apple,
                OriginalTransactionId = transaction.OriginalTransactionId,
                CreatedAt = DateTime.UtcNow,
            };
            _dbContext.UserSubscriptions.Add(subscription);
        }

        subscription.ProductId = transaction.ProductId;
        subscription.Environment = transaction.Environment;
        subscription.PurchasedAt = transaction.PurchasedAt;
        subscription.ExpiresAt = transaction.ExpiresAt;
        subscription.RevokedAt = transaction.RevokedAt;
        subscription.Status = status;
        subscription.LastVerifiedAt = DateTime.UtcNow;
        subscription.UpdatedAt = DateTime.UtcNow;
        await _dbContext.SaveChangesAsync(cancellationToken);

        return Ok(new PremiumStatusDto
        {
            IsPremium = status == SubscriptionStatus.Active &&
                        transaction.ExpiresAt > DateTime.UtcNow,
            ProductId = transaction.ProductId,
            ExpiresAt = transaction.ExpiresAt,
        });
    }

    private Guid GetUserId()
    {
        var claim = User.FindFirst(ClaimTypes.NameIdentifier) ??
                    User.FindFirst("sub");
        if (claim == null || !Guid.TryParse(claim.Value, out var userId))
            throw new UnauthorizedAccessException(
                "Kullanıcı kimliği doğrulanamadı.");
        return userId;
    }
}
