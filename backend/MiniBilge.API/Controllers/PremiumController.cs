using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using MiniBilge.Application.DTOs.Premium;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
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
    private readonly ISubscriptionService _subscriptionService;
    private readonly IEntitlementService _entitlementService;
    private readonly IAppStoreNotificationVerifier _notificationVerifier;
    private readonly IAppStoreNotificationHandler _notificationHandler;
    private readonly IGooglePlayNotificationHandler _googleNotificationHandler;
    private readonly GooglePlayOptions _googlePlayOptions;
    private readonly ILogger<PremiumController> _logger;

    public PremiumController(
        ApplicationDbContext dbContext,
        IApplePurchaseVerifier appleVerifier,
        ISubscriptionService subscriptionService,
        IEntitlementService entitlementService,
        IAppStoreNotificationVerifier notificationVerifier,
        IAppStoreNotificationHandler notificationHandler,
        IGooglePlayNotificationHandler googleNotificationHandler,
        IOptions<GooglePlayOptions> googlePlayOptions,
        ILogger<PremiumController> logger)
    {
        _dbContext = dbContext;
        _appleVerifier = appleVerifier;
        _subscriptionService = subscriptionService;
        _entitlementService = entitlementService;
        _notificationVerifier = notificationVerifier;
        _notificationHandler = notificationHandler;
        _googleNotificationHandler = googleNotificationHandler;
        _googlePlayOptions = googlePlayOptions.Value;
        _logger = logger;
    }

    [HttpGet("status")]
    public async Task<ActionResult<PremiumStatusDto>> GetStatus(
        CancellationToken cancellationToken)
    {
        var userId = GetUserId();
        var entitlement = await _entitlementService.GetForUserAsync(
            userId, cancellationToken);

        return Ok(new PremiumStatusDto
        {
            IsPremium = entitlement.IsPremium,
            ProductId = entitlement.ProductId,
            ExpiresAt = entitlement.ExpiresAt,
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

        var isNewSubscription = subscription == null;
        if (isNewSubscription)
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

        try
        {
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException) when (isNewSubscription)
        {
            // StoreKit aynı işlemi eşzamanlı birden çok kez teslim edebiliyor (kuyruktaki
            // yenileme işlemleri) — iki istek aynı anda aynı OriginalTransactionId için satır
            // oluşturmaya çalışıp unique index'e çarpabilir. Diğer istek kazandı: bu entity'yi
            // tracker'dan çıkar (aksi halde tekrar SaveChanges'te aynı hatayı verir) ve
            // gerçek satırı bulup üzerine güncelle.
            _dbContext.Entry(subscription!).State = EntityState.Detached;
            subscription = await _dbContext.UserSubscriptions
                .SingleAsync(
                    x => x.Provider == SubscriptionProvider.Apple &&
                         x.OriginalTransactionId == transaction.OriginalTransactionId,
                    cancellationToken);

            if (subscription.UserId != userId)
                return Conflict(new
                {
                    message = "Bu abonelik başka bir MiniBilge hesabına bağlı.",
                });

            subscription.ProductId = transaction.ProductId;
            subscription.Environment = transaction.Environment;
            subscription.PurchasedAt = transaction.PurchasedAt;
            subscription.ExpiresAt = transaction.ExpiresAt;
            subscription.RevokedAt = transaction.RevokedAt;
            subscription.Status = status;
            subscription.LastVerifiedAt = DateTime.UtcNow;
            subscription.UpdatedAt = DateTime.UtcNow;
            await _dbContext.SaveChangesAsync(cancellationToken);
        }

        await RecordTransactionAsync(userId, transaction, status, cancellationToken);
        _entitlementService.Invalidate(userId);

        return Ok(new PremiumStatusDto
        {
            IsPremium = status == SubscriptionStatus.Active &&
                        transaction.ExpiresAt > DateTime.UtcNow,
            ProductId = transaction.ProductId,
            ExpiresAt = transaction.ExpiresAt,
        });
    }

    // Idempotent denetim kaydı (best-effort): audit başarısız olsa da satın alma doğrulaması bozulmaz.
    // (Provider, DedupKey) benzersiz olduğundan aynı dönemin tekrar doğrulanması yeni satır üretmez.
    private async Task RecordTransactionAsync(
        Guid userId,
        VerifiedAppleTransaction transaction,
        SubscriptionStatus status,
        CancellationToken cancellationToken)
    {
        try
        {
            var dedupKey = $"{transaction.OriginalTransactionId}:{transaction.ExpiresAt:O}";
            var exists = await _dbContext.PurchaseTransactions
                .AnyAsync(
                    x => x.Provider == SubscriptionProvider.Apple && x.DedupKey == dedupKey,
                    cancellationToken);
            if (exists)
                return;

            _dbContext.PurchaseTransactions.Add(new PurchaseTransaction
            {
                Id = Guid.NewGuid(),
                UserId = userId,
                Provider = SubscriptionProvider.Apple,
                DedupKey = dedupKey,
                Source = "client_verify",
                OriginalTransactionId = transaction.OriginalTransactionId,
                TransactionId = transaction.TransactionId,
                ProductId = transaction.ProductId,
                Environment = transaction.Environment,
                Status = status,
                PurchasedAt = transaction.PurchasedAt,
                ExpiresAt = transaction.ExpiresAt,
                ProcessedAt = DateTime.UtcNow,
                CreatedAt = DateTime.UtcNow,
            });
            await _dbContext.SaveChangesAsync(cancellationToken);
        }
        catch (DbUpdateException)
        {
            // Eşzamanlı çift kayıt (unique ihlali) — idempotency zaten sağlandı, yoksay.
        }
    }

    /// <summary>
    /// Apple App Store Server Notifications V2 alıcısı. Apple sunucusu çağırır;
    /// kimlik JWS imzasıyla doğrulanır (Bearer token yok → AllowAnonymous).
    /// </summary>
    [AllowAnonymous]
    [HttpPost("webhook/apple")]
    public async Task<IActionResult> AppleWebhook(
        [FromBody] AppleWebhookPayload body,
        CancellationToken cancellationToken)
    {
        if (string.IsNullOrWhiteSpace(body?.SignedPayload))
            return BadRequest();

        AppStoreServerNotification notification;
        try
        {
            notification = _notificationVerifier.Verify(body.SignedPayload);
        }
        catch (Exception ex)
        {
            // Doğrulama başarısız → sahte/bozuk bildirim. 400 döndür (retry faydasız).
            _logger.LogWarning(ex, "App Store bildirimi doğrulanamadı.");
            return BadRequest();
        }

        try
        {
            await _notificationHandler.HandleAsync(notification, cancellationToken);
            return Ok();
        }
        catch (Exception ex)
        {
            // Bizim tarafımızdaki geçici hata → 500 (Apple tekrar dener).
            _logger.LogError(ex,
                "App Store bildirimi işlenemedi. UUID={Uuid}", notification.NotificationUuid);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }
    }

    /// <summary>
    /// Google Play RTDN (Pub/Sub push) alıcısı. Kimlik, paylaşılan gizli token ile
    /// doğrulanır (?token=). 2xx = ack, 5xx = Pub/Sub tekrar dener.
    /// </summary>
    [AllowAnonymous]
    [HttpPost("webhook/google")]
    public async Task<IActionResult> GoogleWebhook(
        [FromBody] GooglePlayRtdnPayload body,
        [FromQuery] string? token,
        CancellationToken cancellationToken)
    {
        if (!IsValidPushToken(token))
        {
            _logger.LogWarning("Google Play webhook: geçersiz push token.");
            return Unauthorized();
        }

        var data = body?.Message?.Data;
        var messageId = body?.Message?.MessageId;
        if (string.IsNullOrWhiteSpace(data) || string.IsNullOrWhiteSpace(messageId))
            return Ok(); // İşlenecek mesaj yok → ack.

        GooglePlayDeveloperNotification? notification;
        try
        {
            var json = Encoding.UTF8.GetString(Convert.FromBase64String(data));
            notification = System.Text.Json.JsonSerializer.Deserialize<GooglePlayDeveloperNotification>(json);
        }
        catch (Exception ex)
        {
            // Bozuk/çözülemeyen mesaj → tekrar denemek faydasız, ack ver (poison önleme).
            _logger.LogWarning(ex, "Google Play bildirimi çözümlenemedi.");
            return Ok();
        }

        if (notification == null)
            return Ok();

        try
        {
            await _googleNotificationHandler.HandleAsync(notification, messageId, cancellationToken);
            return Ok();
        }
        catch (Exception ex)
        {
            // Geçici hata (DB/Play API) → 500, Pub/Sub tekrar dener.
            _logger.LogError(ex,
                "Google Play bildirimi işlenemedi. MessageId={MessageId}", messageId);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }
    }

    private bool IsValidPushToken(string? token)
    {
        var expected = _googlePlayOptions.PushToken;
        if (string.IsNullOrEmpty(expected) || string.IsNullOrEmpty(token))
            return false;
        return CryptographicOperations.FixedTimeEquals(
            Encoding.UTF8.GetBytes(token),
            Encoding.UTF8.GetBytes(expected));
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
