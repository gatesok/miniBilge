using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IMatchInvitationRepository
{
    /// <summary>Yeni davet oluşturur (Pending, ExpiresAt = now + 60s).</summary>
    Task<MatchInvitation> CreateAsync(Guid inviterId, Guid inviteeId, Guid? subjectId);

    /// <summary>ID ile getirir.</summary>
    Task<MatchInvitation?> GetByIdAsync(Guid id);

    /// <summary>Belirli bir invitee'nin bekleyen davetlerini getirir.</summary>
    Task<List<MatchInvitation>> GetPendingForInviteeAsync(Guid inviteeId);

    /// <summary>Durumu günceller ve opsiyonel olarak matchSessionId atar.</summary>
    Task UpdateStatusAsync(Guid id, MatchInvitationStatus status, Guid? matchSessionId = null);

    /// <summary>Aynı inviter'dan gelen diğer pending davetleri getirir (1 davet kabul edilince expire etmek için).</summary>
    Task<List<MatchInvitation>> GetOtherPendingByInviterAsync(Guid inviterId, Guid excludeInvitationId);

    /// <summary>Süresi geçmiş Pending davetleri Expired olarak işaretler.</summary>
    Task ExpireOldAsync();
}
