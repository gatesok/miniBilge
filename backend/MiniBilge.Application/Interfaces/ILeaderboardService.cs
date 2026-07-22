using MiniBilge.Application.DTOs.Leaderboard;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces;

public interface ILeaderboardService
{
    Task<List<LeaderboardEntryDto>> GetGlobalLeaderboardAsync(
        int topN = 50,
        CompetitionAudience audience = CompetitionAudience.Child);
    Task<LeaderboardEntryDto?> GetChildRankAsync(Guid childProfileId);
    Task<List<LeaderboardEntryDto>> GetTopNAsync(
        int n,
        CompetitionAudience audience = CompetitionAudience.Child);
}
