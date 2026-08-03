using MiniBilge.Application.DTOs.Tournament;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class AdultTournamentService : IAdultTournamentService
{
    private readonly IAdultTournamentRepository _repo;
    private readonly IChildProfileRepository _childProfileRepo;
    private readonly INotificationService _notificationService;

    public AdultTournamentService(
        IAdultTournamentRepository repo,
        IChildProfileRepository childProfileRepo,
        INotificationService notificationService)
    {
        _repo = repo;
        _childProfileRepo = childProfileRepo;
        _notificationService = notificationService;
    }

    public async Task RecordResultAsync(Guid childProfileId, string? categoryKey, int points, bool isWin)
    {
        if (string.IsNullOrWhiteSpace(categoryKey)) return;

        var baseKey = categoryKey.Split(':', 2)[0].Trim().ToLowerInvariant();
        if (!EntertainmentTopics.All.ContainsKey(baseKey)) return;

        await _repo.UpsertAsync(childProfileId, CurrentWeekStart(), baseKey, points, isWin);
    }

    public IReadOnlyList<TournamentCategoryDto> GetCategories()
        => EntertainmentTopics.All
            .Select(kv => new TournamentCategoryDto
            {
                Key   = kv.Key,
                Label = kv.Value.Label,
                Emoji = kv.Value.Emoji,
            })
            .ToList();

    public async Task<TournamentWeekDto> GetWeeklyLeaderboardAsync(string categoryKey, int topN, Guid? meChildProfileId)
    {
        var baseKey = (categoryKey ?? string.Empty).Split(':', 2)[0].Trim().ToLowerInvariant();
        if (!EntertainmentTopics.All.TryGetValue(baseKey, out var cfg))
            throw new InvalidOperationException("Geçersiz turnuva kategorisi.");

        var week = CurrentWeekStart();
        var ordered = await _repo.GetWeeklyOrderedAsync(week, baseKey);

        var ranked = ordered
            .Select((e, i) => (entry: e, rank: i + 1))
            .ToList();

        var dto = new TournamentWeekDto
        {
            CategoryKey   = baseKey,
            CategoryLabel = cfg.Label,
            CategoryEmoji = cfg.Emoji,
            WeekStart     = week,
            Entries       = ranked.Take(Math.Max(1, topN)).Select(x => Map(x.entry, x.rank)).ToList(),
        };

        if (meChildProfileId.HasValue)
        {
            var mine = ranked.FirstOrDefault(x => x.entry.ChildProfileId == meChildProfileId.Value);
            if (mine.entry != null)
                dto.Me = Map(mine.entry, mine.rank);
        }

        return dto;
    }

    public async Task NotifyWeeklyStartAsync()
    {
        var adultIds = await _childProfileRepo.GetAdultIdsAsync();
        if (adultIds.Count == 0) return;
        await _notificationService.SendTournamentStartedAsync(adultIds);
    }

    public async Task NotifyWeeklyEndingAsync()
    {
        var adultIds = await _childProfileRepo.GetAdultIdsAsync();
        if (adultIds.Count == 0) return;
        await _notificationService.SendTournamentEndingAsync(adultIds);
    }

    private static TournamentLeaderboardEntryDto Map(AdultTournamentEntry e, int rank)
        => new()
        {
            ChildProfileId = e.ChildProfileId,
            ChildName      = e.ChildProfile?.Name ?? string.Empty,
            AvatarImageUrl = e.ChildProfile?.AvatarImageUrl,
            Points         = e.Points,
            Wins           = e.Wins,
            GamesPlayed    = e.GamesPlayed,
            Rank           = rank,
        };

    /// <summary>Bu haftanın Pazartesi başlangıcı (Europe/Istanbul).</summary>
    private static DateOnly CurrentWeekStart()
    {
        DateOnly today;
        try
        {
            var zone = TimeZoneInfo.FindSystemTimeZoneById("Europe/Istanbul");
            today = DateOnly.FromDateTime(TimeZoneInfo.ConvertTimeFromUtc(DateTime.UtcNow, zone));
        }
        catch (TimeZoneNotFoundException)
        {
            today = DateOnly.FromDateTime(DateTime.UtcNow.AddHours(3));
        }

        var diff = (7 + (int)today.DayOfWeek - (int)DayOfWeek.Monday) % 7;
        return today.AddDays(-diff);
    }
}
