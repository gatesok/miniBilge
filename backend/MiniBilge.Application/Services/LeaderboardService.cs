using MiniBilge.Application.DTOs.Leaderboard;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;

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

    public async Task<List<LeaderboardEntryDto>> GetGlobalLeaderboardAsync(int topN = 50)
    {
        return await GetTopNAsync(topN);
    }

    public async Task<LeaderboardEntryDto?> GetChildRankAsync(Guid childProfileId)
    {
        var (allChildren, progressMap) = await GetChildrenWithProgress();
        var ranked = allChildren
            .OrderByDescending(c => progressMap.GetValueOrDefault(c.Id, 0))
            .ThenByDescending(c => c.TotalStars)
            .ToList();

        var index = ranked.FindIndex(c => c.Id == childProfileId);
        if (index < 0) return null;

        var child = ranked[index];
        return new LeaderboardEntryDto
        {
            ChildProfileId = child.Id,
            ChildName = child.Name,
            AvatarImageUrl = child.AvatarImageUrl,
            TotalCoins = child.TotalCoins,
            TotalScore = progressMap.GetValueOrDefault(child.Id, 0),
            TotalStars = child.TotalStars,
            Rank = index + 1,
            GradeLevel = child.GradeLevel.ToString()
        };
    }

    public async Task<List<LeaderboardEntryDto>> GetTopNAsync(int n)
    {
        var (allChildren, progressMap) = await GetChildrenWithProgress();
        return allChildren
            .Where(c => progressMap.GetValueOrDefault(c.Id, 0) > 0 || c.TotalStars > 0)
            .OrderByDescending(c => progressMap.GetValueOrDefault(c.Id, 0))
            .ThenByDescending(c => c.TotalStars)
            .Take(n)
            .Select((c, index) => new LeaderboardEntryDto
            {
                ChildProfileId = c.Id,
                ChildName = c.Name,
                AvatarImageUrl = c.AvatarImageUrl,
                TotalCoins = c.TotalCoins,
                TotalScore = progressMap.GetValueOrDefault(c.Id, 0),
                TotalStars = c.TotalStars,
                Rank = index + 1,
                GradeLevel = c.GradeLevel.ToString()
            })
            .ToList();
    }

    private async Task<(List<MiniBilge.Domain.Entities.ChildProfile>, Dictionary<Guid, int>)> GetChildrenWithProgress()
    {
        var allChildren = await _childProfileRepository.GetAllAsync();
        var allProgress = await _progressRepository.GetAllProgressAsync();
        var progressMap = allProgress.ToDictionary(p => p.ChildId, p => p.TotalScore);
        return (allChildren, progressMap);
    }
}
