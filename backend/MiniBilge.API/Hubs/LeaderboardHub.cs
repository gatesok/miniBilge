using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using MiniBilge.Application.DTOs.Leaderboard;

namespace MiniBilge.API.Hubs;

[Authorize]
public class LeaderboardHub : Hub
{
    /// <summary>
    /// Client bağlandığında çağrılır.
    /// </summary>
    public override async Task OnConnectedAsync()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "leaderboard");
        await base.OnConnectedAsync();
    }

    /// <summary>
    /// Client bağlantısı koptuğunda çağrılır.
    /// </summary>
    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        await Groups.RemoveFromGroupAsync(Context.ConnectionId, "leaderboard");
        await base.OnDisconnectedAsync(exception);
    }
}

/// <summary>
/// Diğer servislerden Hub'a erişim için kullanılan interface.
/// </summary>
public interface ILeaderboardHubClient
{
    Task ReceiveLeaderboardUpdate(List<LeaderboardEntryDto> entries);
}
