using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Services;

/// <summary>
/// P7-M05: Haftalık eğlence turnuvası bildirimleri (Europe/Istanbul).
///  • Pazartesi 10:00 → "Haftalık turnuva başladı" (yetişkinlere)
///  • Pazar     22:00 → "Son 2 saat, sıralamada yüksel" (yetişkinlere)
/// Her slot günde bir kez tetiklenir.
/// </summary>
public class TournamentReminderBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<TournamentReminderBackgroundService> _logger;

    public TournamentReminderBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<TournamentReminderBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger       = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(
            "[TournamentReminder] Başlatıldı — Pzt 10:00 başlangıç, Paz 22:00 bitiş (Europe/Istanbul).");

        DateOnly? lastStartDate  = null;
        DateOnly? lastEndingDate = null;

        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromMinutes(15), stoppingToken);
            if (stoppingToken.IsCancellationRequested) break;

            var now   = NowInIstanbul();
            var today = DateOnly.FromDateTime(now);

            // Pazartesi 10:00 — turnuva başladı
            if (now.DayOfWeek == DayOfWeek.Monday && now.Hour >= 10 && lastStartDate != today)
            {
                lastStartDate = today;
                await FireAsync(
                    "başlangıç",
                    svc => svc.NotifyWeeklyStartAsync());
            }

            // Pazar 22:00 — turnuva bitmek üzere (son ~2 saat)
            if (now.DayOfWeek == DayOfWeek.Sunday && now.Hour >= 22 && lastEndingDate != today)
            {
                lastEndingDate = today;
                await FireAsync(
                    "bitiş",
                    svc => svc.NotifyWeeklyEndingAsync());
            }
        }
    }

    private async Task FireAsync(string label, Func<IAdultTournamentService, Task> action)
    {
        try
        {
            using var scope = _scopeFactory.CreateScope();
            var service = scope.ServiceProvider.GetRequiredService<IAdultTournamentService>();
            await action(service);
            _logger.LogInformation("[TournamentReminder] {Label} bildirimi gönderildi.", label);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[TournamentReminder] {Label} bildiriminde hata.", label);
        }
    }

    private static DateTime NowInIstanbul()
    {
        try
        {
            var zone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
            return TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone);
        }
        catch (TimeZoneNotFoundException)
        {
            return DateTime.UtcNow.AddHours(3);
        }
    }
}
