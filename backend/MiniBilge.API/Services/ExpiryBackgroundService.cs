using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Services;

/// <summary>
/// Her 15 dakikada bir süresi dolmuş challenge, match invitation ve terk edilmiş
/// canlı yarış kuyruk isteklerini Expired yapar (ve rezerve edilen kotayı iade eder).
/// </summary>
public class ExpiryBackgroundService : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromMinutes(15);

    /// <summary>Terk edilmiş kuyruk isteği eşiği — aktif aramaları erken kesmemek için geniş tutulur.</summary>
    private const int StaleMatchRequestSeconds = 300;

    /// <summary>Hiç başlamayan (iki oyuncu da katılmayan) canlı yarış oturumu eşiği.
    /// Rakip bulunduktan sonra hub'a katılım saniyeler sürer; 90 sn güvenli marjdır.</summary>
    private const int StaleMatchSessionSeconds = 90;

    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<ExpiryBackgroundService> _logger;

    public ExpiryBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<ExpiryBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger       = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("[ExpiryJob] Başlatıldı — her {Minutes} dakikada çalışır.",
            Interval.TotalMinutes);

        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(Interval, stoppingToken);
            if (stoppingToken.IsCancellationRequested) break;

            try
            {
                using var scope = _scopeFactory.CreateScope();

                var challengeService = scope.ServiceProvider
                    .GetRequiredService<IChallengeService>();
                await challengeService.ExpireOldChallengesAsync();

                var invitationService = scope.ServiceProvider
                    .GetRequiredService<IMatchInvitationService>();
                await invitationService.ExpireOldAsync();

                var matchmakingService = scope.ServiceProvider
                    .GetRequiredService<IMatchmakingService>();
                await matchmakingService.ExpireOldRequestsAsync(StaleMatchRequestSeconds);
                await matchmakingService.ExpireStaleMatchSessionsAsync(StaleMatchSessionSeconds);

                _logger.LogDebug("[ExpiryJob] Expire taraması tamamlandı.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[ExpiryJob] Expire taraması sırasında hata.");
            }
        }
    }
}
