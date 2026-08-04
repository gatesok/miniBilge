using MiniBilge.Application.DTOs.Tournament;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Options;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class AdultTournamentService : IAdultTournamentService
{
    /// <summary>Bir kategoride gösterilecek maksimum sıralama sayısı.</summary>
    private const int MaxLeaderboardSize = 10;

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

    public async Task RecordResultAsync(Guid childProfileId, string? categoryKey, int basePoints, bool isWin, string? difficulty, int correctCount, int answeredCount)
    {
        if (string.IsNullOrWhiteSpace(categoryKey)) return;

        var baseKey = categoryKey.Split(':', 2)[0].Trim().ToLowerInvariant();
        if (!EntertainmentTopics.All.ContainsKey(baseKey)) return;

        var points = (int)Math.Round(Math.Max(0, basePoints) * DifficultyMultiplier(difficulty));
        await _repo.UpsertAsync(childProfileId, CurrentWeekStart(), baseKey, points, isWin, correctCount, answeredCount);
    }

    public async Task<AdultCategoryWeeklyStats?> GetWeeklyCategoryStatsAsync(Guid childProfileId, string categoryKey)
    {
        var baseKey = (categoryKey ?? string.Empty).Split(':', 2)[0].Trim().ToLowerInvariant();
        if (!EntertainmentTopics.All.ContainsKey(baseKey)) return null;

        var entry = await _repo.GetEntryAsync(childProfileId, CurrentWeekStart(), baseKey);
        return entry == null ? null : new AdultCategoryWeeklyStats(entry.CorrectCount, entry.AnsweredCount);
    }

    /// <summary>Zorluk puan çarpanı: Kolay ×1, Orta ×1.5, Zor ×2 (bilinmeyen → ×1).</summary>
    private static decimal DifficultyMultiplier(string? difficulty)
    {
        var d = (difficulty ?? string.Empty).Trim().ToLowerInvariant();
        if (d.Contains("zor")) return 2.0m;
        if (d.Contains("orta")) return 1.5m;
        return 1.0m;
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

        // İstemci ne isterse istesin en fazla ilk 10 döner (sayfa yapısı + performans).
        var limit = Math.Clamp(topN, 1, MaxLeaderboardSize);

        var dto = new TournamentWeekDto
        {
            CategoryKey   = baseKey,
            CategoryLabel = cfg.Label,
            CategoryEmoji = cfg.Emoji,
            WeekStart     = week,
            Entries       = ranked.Take(limit).Select(x => Map(x.entry, x.rank)).ToList(),
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
