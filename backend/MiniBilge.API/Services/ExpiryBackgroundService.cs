using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Services;

/// <summary>
/// Her 15 dakikada bir süresi dolmuş challenge ve match invitation kayıtlarını Expired yapar.
/// </summary>
public class ExpiryBackgroundService : BackgroundService
{
    private static readonly TimeSpan Interval = TimeSpan.FromMinutes(15);
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

                _logger.LogDebug("[ExpiryJob] Expire taraması tamamlandı.");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "[ExpiryJob] Expire taraması sırasında hata.");
            }
        }
    }
}
