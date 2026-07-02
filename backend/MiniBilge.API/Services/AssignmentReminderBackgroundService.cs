using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.API.Services;

/// <summary>
/// Her gün UTC 08:00'de çalışır.
/// Son tarihi yarın olan ve henüz tamamlanmamış ödevler için öğrencilere push bildirimi gönderir.
/// Yalnızca ödevi tamamlamamış öğrencilere bildirim gider.
/// </summary>
public class AssignmentReminderBackgroundService : BackgroundService
{
    private readonly IServiceScopeFactory _scopeFactory;
    private readonly ILogger<AssignmentReminderBackgroundService> _logger;

    public AssignmentReminderBackgroundService(
        IServiceScopeFactory scopeFactory,
        ILogger<AssignmentReminderBackgroundService> logger)
    {
        _scopeFactory = scopeFactory;
        _logger       = logger;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("[AssignmentReminder] Başlatıldı — her gün UTC 08:00'de çalışır.");

        DateOnly? lastRunDate = null;

        while (!stoppingToken.IsCancellationRequested)
        {
            await Task.Delay(TimeSpan.FromHours(1), stoppingToken);
            if (stoppingToken.IsCancellationRequested) break;

            var now   = DateTime.UtcNow;
            var today = DateOnly.FromDateTime(now);

            // Günde bir kez, saat 08:00 UTC sonrasında çalış
            if (now.Hour >= 8 && lastRunDate != today)
            {
                lastRunDate = today;
                try
                {
                    using var scope = _scopeFactory.CreateScope();
                    var classroomService = scope.ServiceProvider
                        .GetRequiredService<IClassroomService>();
                    await classroomService.SendDueTomorrowRemindersAsync();
                    _logger.LogInformation("[AssignmentReminder] Ödev hatırlatmaları gönderildi ({Date}).", today);
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, "[AssignmentReminder] Hatırlatma gönderiminde hata.");
                }
            }
        }
    }
}
