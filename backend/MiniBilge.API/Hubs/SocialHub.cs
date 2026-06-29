using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.SignalR;
using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using System.Collections.Concurrent;

namespace MiniBilge.API.Hubs;

/// <summary>
/// SocialHub — arkadaşlık istekleri ve yarış davetlerini gerçek zamanlı iletir.
///
/// İstemci → Sunucu metodları:
///   • RegisterPresence(string childId)  — bağlantıyı childId ile kaydet
///
/// Sunucu → İstemci olayları:
///   • FriendRequestReceived(FriendRequestNotification)
///   • MatchInviteReceived(MatchInviteNotification)
///   • MatchInviteResponded(MatchInviteResponseNotification)
/// </summary>
[Authorize]
public class SocialHub : Hub
{
    private readonly IFriendshipRepository _friendshipRepository;
    private readonly IMatchInvitationRepository _matchInvitationRepository;
    private readonly IChildProfileRepository _childProfileRepository;
    private readonly ILogger<SocialHub> _logger;

    // childId → (connectionId, lastSeen) — TTL tabanlı presence
    private static readonly ConcurrentDictionary<string, (string ConnectionId, DateTime LastSeen)> _childConnections = new();

    // Online sayılmak için son heartbeat'in bu süreden taze olması gerekir
    private static readonly TimeSpan OnlineTtl = TimeSpan.FromMinutes(2);

    public SocialHub(
        IFriendshipRepository friendshipRepository,
        IMatchInvitationRepository matchInvitationRepository,
        IChildProfileRepository childProfileRepository,
        ILogger<SocialHub> logger)
    {
        _friendshipRepository      = friendshipRepository;
        _matchInvitationRepository = matchInvitationRepository;
        _childProfileRepository    = childProfileRepository;
        _logger                    = logger;
    }

    // ── Lifecycle ────────────────────────────────────────────────────────────

    public override async Task OnConnectedAsync()
    {
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            _childConnections[childId] = (Context.ConnectionId, DateTime.UtcNow);
            _logger.LogInformation("[SOCIAL HUB] Connected: {ChildId}", childId);
        }
        await base.OnConnectedAsync();
    }

    public override async Task OnDisconnectedAsync(Exception? exception)
    {
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            _childConnections.TryRemove(childId, out _);
            _logger.LogInformation("[SOCIAL HUB] Disconnected: {ChildId}", childId);
        }
        await base.OnDisconnectedAsync(exception);
    }

    // ── İstemciden çağrılabilir metodlar ────────────────────────────────────

    /// <summary>Bağlantıyı childId ile ilişkilendirir, timestamp günceller.</summary>
    public Task RegisterPresence(string childId)
    {
        _childConnections[childId] = (Context.ConnectionId, DateTime.UtcNow);
        _logger.LogDebug("[SOCIAL HUB] Presence registered: {ChildId}", childId);
        return Task.CompletedTask;
    }

    /// <summary>İstemci her 30s'de çağırır — "hâlâ buradayım" sinyali.</summary>
    public Task Heartbeat(string childId)
    {
        if (_childConnections.TryGetValue(childId, out var entry))
            _childConnections[childId] = (entry.ConnectionId, DateTime.UtcNow);
        _logger.LogDebug("[SOCIAL HUB] Heartbeat: {ChildId}", childId);
        return Task.CompletedTask;
    }

    /// <summary>İstemci uygulamayı kapatmadan önce çağırır — anında offline.</summary>
    public Task SetOffline(string childId)
    {
        _childConnections.TryRemove(childId, out _);
        _logger.LogDebug("[SOCIAL HUB] SetOffline: {ChildId}", childId);
        return Task.CompletedTask;
    }

    // ── Statik yardımcılar ────────────────────────────────────────────────────

    /// <summary>Son heartbeat 2 dakikadan tazeyse online kabul eder.</summary>
    public static bool IsOnline(string childId)
        => _childConnections.TryGetValue(childId, out var e)
           && DateTime.UtcNow - e.LastSeen < OnlineTtl;

    /// <summary>Bildirim göndermek için connectionId döner (SocialHubNotifier kullanır).</summary>
    public static bool TryGetConnection(string childId, out string? connectionId)
    {
        if (_childConnections.TryGetValue(childId, out var e)
            && DateTime.UtcNow - e.LastSeen < OnlineTtl)
        {
            connectionId = e.ConnectionId;
            return true;
        }
        connectionId = null;
        return false;
    }
}

// ── Bildirim DTO'ları ────────────────────────────────────────────────────────

public record FriendRequestNotification(
    Guid   FriendshipId,
    Guid   RequesterId,
    string RequesterName,
    string RequesterAvatar);

public record MatchInviteNotification(
    Guid    InvitationId,
    Guid    InviterId,
    string  InviterName,
    string  InviterAvatar,
    Guid?   SubjectId,
    string? SubjectName,
    DateTime ExpiresAt);

public record MatchInviteResponseNotification(
    Guid   InvitationId,
    Guid   InviteeId,
    string InviteeName,
    bool   Accepted,
    Guid?  MatchSessionId);
