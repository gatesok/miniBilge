using MiniBilge.Application.DTOs.Leaderboard;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class LeaderboardService : ILeaderboardService
{
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly IProgressRepository _progressRepository;

    public LeaderboardService(
        IChildProfileRepository childProfileRepository,
        IProgressRepository progressRepository)
    {
        _childProfileRepository = childProfileRepository;
        _progressRepository = progressRepository;
    }

    public async Task<List<LeaderboardEntryDto>> GetGlobalLeaderboardAsync(
        int topN = 50,
        CompetitionAudience audience = CompetitionAudience.Child)
    {
        return await GetTopNAsync(topN, audience);
    }

    public async Task<LeaderboardEntryDto?> GetChildRankAsync(Guid childProfileId)
    {
        var (allChildren, progressMap) = await GetChildrenWithProgress();
        var target = allChildren.FirstOrDefault(c => c.Id == childProfileId);
        if (target is null) return null;

        var audience = target.GradeLevel == GradeLevel.Adult
            ? CompetitionAudience.Adult
            : CompetitionAudience.Child;
        var ranked = FilterAudience(allChildren, audience)
            .OrderByDescending(c => ScoreFor(c, progressMap, audience))
            .ThenByDescending(c => c.TotalStars)
            .ToList();

        var index = ranked.FindIndex(c => c.Id == childProfileId);
        if (index < 0) return null;

        return Map(ranked[index], index + 1, progressMap, audience);
    }

    public async Task<List<LeaderboardEntryDto>> GetTopNAsync(
        int n,
        CompetitionAudience audience = CompetitionAudience.Child)
    {
        var (allChildren, progressMap) = await GetChildrenWithProgress();
        return FilterAudience(allChildren, audience)
            .Where(c => ScoreFor(c, progressMap, audience) > 0)
            .OrderByDescending(c => ScoreFor(c, progressMap, audience))
            .ThenByDescending(c => c.TotalStars)
            .Take(n)
            .Select((c, index) => Map(c, index + 1, progressMap, audience))
            .ToList();
    }

    private static IEnumerable<MiniBilge.Domain.Entities.ChildProfile> FilterAudience(
        IEnumerable<MiniBilge.Domain.Entities.ChildProfile> profiles,
        CompetitionAudience audience) => profiles.Where(profile =>
            audience == CompetitionAudience.Adult
                ? profile.GradeLevel == GradeLevel.Adult
                : profile.GradeLevel != GradeLevel.Adult);

    private static int ScoreFor(
        MiniBilge.Domain.Entities.ChildProfile profile,
        IReadOnlyDictionary<Guid, int> progressMap,
        CompetitionAudience audience) => audience == CompetitionAudience.Adult
            ? profile.AdultCompetitionPoints
            : progressMap.GetValueOrDefault(profile.Id, 0);

    private static LeaderboardEntryDto Map(
        MiniBilge.Domain.Entities.ChildProfile profile,
        int rank,
        IReadOnlyDictionary<Guid, int> progressMap,
        CompetitionAudience audience) => new()
    {
        ChildProfileId = profile.Id,
        ChildName = profile.Name,
        AvatarImageUrl = profile.AvatarImageUrl,
        TotalCoins = profile.TotalCoins,
        TotalScore = ScoreFor(profile, progressMap, audience),
        TotalStars = profile.TotalStars,
        Rank = rank,
        GradeLevel = profile.GradeLevel.ToString(),
        ProfileType = audience.ToString(),
        Wins = audience == CompetitionAudience.Adult ? profile.AdultCompetitionWins : 0,
        GamesPlayed = audience == CompetitionAudience.Adult
            ? profile.AdultCompetitionGamesPlayed
            : 0
    };

    private async Task<(List<MiniBilge.Domain.Entities.ChildProfile>, Dictionary<Guid, int>)> GetChildrenWithProgress()
    {
        var allChildren = await _childProfileRepository.GetAllAsync();
        var allProgress = await _progressRepository.GetAllProgressAsync();
        var progressMap = allProgress.ToDictionary(p => p.ChildId, p => p.TotalScore);
        return (allChildren, progressMap);
    }
}
