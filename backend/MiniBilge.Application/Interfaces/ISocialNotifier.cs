using MiniBilge.Application.DTOs.Friendship;
using MiniBilge.Application.DTOs.Match;

namespace MiniBilge.Application.Interfaces;

/// <summary>
/// SocialHub üzerinden gerçek zamanlı bildirim göndermek için servis sözleşmesi.
/// Implementasyon MiniBilge.API.Services katmanındadır (IHubContext erişimi gerektirir).
/// </summary>
public interface ISocialNotifier
{
    /// <summary>Arkadaşlık isteği alındığında addressee'ye bildirim gönder.</summary>
    Task NotifyFriendRequestAsync(Guid addresseeId, FriendDto requester, Guid friendshipId);

    /// <summary>Yarış daveti alındığında invitee'ye bildirim gönder.</summary>
    Task NotifyMatchInviteAsync(Guid inviteeId, MatchInvitationDto invitation);

    /// <summary>Davet yanıtlandığında inviter'a bildirim gönder.</summary>
    Task NotifyMatchInviteResponseAsync(Guid inviterId, MatchInvitationDto invitation);

    /// <summary>Başka bir davet kabul edildiği için bu davet geçersizleşince invitee'ye bildirim gönder.</summary>
    Task NotifyMatchInviteExpiredAsync(Guid inviteeId, Guid invitationId, string inviterName);
}
