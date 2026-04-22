using MiniBilge.Application.DTOs.Leaderboard;

namespace MiniBilge.Application.Interfaces;

/// <summary>
/// Realtime leaderboard bildirimi için soyutlama.
/// Application katmanı Hub'a doğrudan bağımlı olmamak için bu interface kullanılır.
/// </summary>
public interface ILeaderboardNotifier
{
    Task NotifyLeaderboardUpdatedAsync(List<LeaderboardEntryDto> topEntries);
}
