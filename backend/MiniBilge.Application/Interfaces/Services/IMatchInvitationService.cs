using MiniBilge.Application.DTOs.Match;

namespace MiniBilge.Application.Interfaces.Services;

public interface IMatchInvitationService
{
    /// <summary>Arkadaşa yarış daveti gönder.</summary>
    Task<MatchInvitationDto> SendInviteAsync(Guid inviterId, Guid inviteeId, Guid? subjectId);

    /// <summary>Daveti kabul veya reddet. Kabul edilirse MatchSession oluşturulur.</summary>
    Task<MatchInvitationDto> RespondAsync(Guid invitationId, Guid inviteeId, bool accept);

    /// <summary>Invitee'nin bekleyen davetlerini getir.</summary>
    Task<List<MatchInvitationDto>> GetPendingForInviteeAsync(Guid inviteeId);

    /// <summary>Süresi dolmuş davetleri temizle (background job).</summary>
    Task ExpireOldAsync();

    /// <summary>Inviter'ın kendi davetini iptal eder, invitee'ye bildirim gönderir.</summary>
    Task CancelAsync(Guid invitationId, Guid inviterId);

    /// <summary>Inviter'ın gönderdiği bekleyen davetleri getir.</summary>
    Task<List<MatchInvitationDto>> GetPendingForInviterAsync(Guid inviterId);
}
