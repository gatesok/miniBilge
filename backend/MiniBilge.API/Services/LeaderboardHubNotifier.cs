using Microsoft.AspNetCore.SignalR;
using MiniBilge.API.Hubs;
using MiniBilge.Application.DTOs.Leaderboard;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Services;

public class LeaderboardHubNotifier : ILeaderboardNotifier
{
    private readonly IHubContext<LeaderboardHub> _hubContext;

    public LeaderboardHubNotifier(IHubContext<LeaderboardHub> hubContext)
    {
        _hubContext = hubContext;
    }

    public async Task NotifyLeaderboardUpdatedAsync(List<LeaderboardEntryDto> topEntries)
    {
        Console.WriteLine($"[HUB] Leaderboard güncelleme mesajı gönderiliyor: {topEntries.Count} entry");
        await _hubContext.Clients.Group("leaderboard")
            .SendAsync("ReceiveLeaderboardUpdate", topEntries);
        Console.WriteLine("[HUB] Mesaj gönderildi!");
    }
}
