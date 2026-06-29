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

    // childId (string) → connectionId — en güncel bağlantıyı tutar
    private static readonly ConcurrentDictionary<string, string> _childConnections = new();

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
        // JWT'den ChildId okunuyorsa otomatik kaydedilir; opsiyonel olarak
        // istemci RegisterPresence'ı da çağırabilir.
        var childId = Context.User?.FindFirst("ChildId")?.Value;
        if (childId != null)
        {
            _childConnections[childId] = Context.ConnectionId;
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

    /// <summary>
    /// İstemci bağlantısını belirli bir childId ile ilişkilendirir.
    /// JWT zaten geçerliyse OnConnectedAsync bu işi yapar; bu metod yedek olarak tutulur.
    /// </summary>
    public Task RegisterPresence(string childId)
    {
        _childConnections[childId] = Context.ConnectionId;
        _logger.LogDebug("[SOCIAL HUB] Presence registered: {ChildId}", childId);
        return Task.CompletedTask;
    }

    // ── Statik yardımcı: diğer servislerden bildirim göndermek için ─────────

    /// <summary>
    /// Belirli bir childId bağlıysa true döner ve connectionId'yi out parametresinde verir.
    /// </summary>
    public static bool TryGetConnection(string childId, out string? connectionId)
        => _childConnections.TryGetValue(childId, out connectionId);
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
