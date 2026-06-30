using Microsoft.AspNetCore.SignalR;
using MiniBilge.API.Hubs;
using MiniBilge.Application.DTOs.Friendship;
using MiniBilge.Application.DTOs.Match;
using MiniBilge.Application.Interfaces;
using MiniBilge.Domain.Enums;
using Microsoft.Extensions.Logging;

namespace MiniBilge.API.Services;

public class SocialHubNotifier : ISocialNotifier
{
    private readonly IHubContext<SocialHub> _hubContext;
    private readonly ILogger<SocialHubNotifier> _logger;

    public SocialHubNotifier(IHubContext<SocialHub> hubContext, ILogger<SocialHubNotifier> logger)
    {
        _hubContext = hubContext;
        _logger     = logger;
    }

    public async Task NotifyFriendRequestAsync(Guid addresseeId, FriendDto requester, Guid friendshipId)
    {
        if (!SocialHub.TryGetConnection(addresseeId.ToString(), out var connectionId) || connectionId is null)
        {
            _logger.LogDebug("[SOCIAL NOTIFIER] FriendRequest: {AddresseeId} is offline", addresseeId);
            return;
        }

        var payload = new FriendRequestNotification(
            FriendshipId:   friendshipId,
            RequesterId:    requester.ChildId,
            RequesterName:  requester.DisplayName,
            RequesterAvatar: requester.AvatarKey ?? string.Empty);

        await _hubContext.Clients.Client(connectionId)
            .SendAsync("FriendRequestReceived", payload);

        _logger.LogInformation("[SOCIAL NOTIFIER] FriendRequestReceived → {AddresseeId}", addresseeId);
    }

    public async Task NotifyMatchInviteAsync(Guid inviteeId, MatchInvitationDto invitation)
    {
        if (!SocialHub.TryGetConnection(inviteeId.ToString(), out var connectionId) || connectionId is null)
        {
            _logger.LogDebug("[SOCIAL NOTIFIER] MatchInvite: {InviteeId} is offline", inviteeId);
            return;
        }

        var payload = new MatchInviteNotification(
            InvitationId:  invitation.Id,
            InviterId:     invitation.InviterId,
            InviterName:   invitation.InviterName,
            InviterAvatar: invitation.InviterAvatar ?? string.Empty,
            SubjectId:     invitation.SubjectId,
            SubjectName:   invitation.SubjectName,
            ExpiresAt:     invitation.ExpiresAt);

        await _hubContext.Clients.Client(connectionId)
            .SendAsync("MatchInviteReceived", payload);

        _logger.LogInformation("[SOCIAL NOTIFIER] MatchInviteReceived → {InviteeId}", inviteeId);
    }

    public async Task NotifyMatchInviteResponseAsync(Guid inviterId, MatchInvitationDto invitation)
    {
        if (!SocialHub.TryGetConnection(inviterId.ToString(), out var connectionId) || connectionId is null)
        {
            _logger.LogDebug("[SOCIAL NOTIFIER] MatchInviteResponse: {InviterId} is offline", inviterId);
            return;
        }

        var accepted = (MatchInvitationStatus)invitation.Status == MatchInvitationStatus.Accepted;
        var payload = new MatchInviteResponseNotification(
            InvitationId:   invitation.Id,
            InviteeId:      invitation.InviteeId,
            InviteeName:    invitation.InviteeName,
            Accepted:       accepted,
            MatchSessionId: invitation.MatchSessionId);

        await _hubContext.Clients.Client(connectionId)
            .SendAsync("MatchInviteResponded", payload);

        _logger.LogInformation("[SOCIAL NOTIFIER] MatchInviteResponded → {InviterId} (accepted={Accepted})",
            inviterId, accepted);
    }

    public async Task NotifyMatchInviteExpiredAsync(Guid inviteeId, Guid invitationId, string inviterName)
    {
        if (!SocialHub.TryGetConnection(inviteeId.ToString(), out var connectionId) || connectionId is null)
        {
            _logger.LogDebug("[SOCIAL NOTIFIER] MatchInviteExpired: {InviteeId} is offline", inviteeId);
            return;
        }

        await _hubContext.Clients.Client(connectionId)
            .SendAsync("MatchInviteExpired", new { InvitationId = invitationId, InviterName = inviterName });

        _logger.LogInformation("[SOCIAL NOTIFIER] MatchInviteExpired → {InviteeId}", inviteeId);
    }
}
