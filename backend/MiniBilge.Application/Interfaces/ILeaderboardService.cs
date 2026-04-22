using MiniBilge.Application.DTOs.Leaderboard;

namespace MiniBilge.Application.Interfaces;

public interface ILeaderboardService
{
    Task<List<LeaderboardEntryDto>> GetGlobalLeaderboardAsync(int topN = 50);
    Task<LeaderboardEntryDto?> GetChildRankAsync(Guid childProfileId);
    Task<List<LeaderboardEntryDto>> GetTopNAsync(int n);
}
