using MiniBilge.Application.DTOs.Match;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class MatchInvitationService : IMatchInvitationService
{
    private readonly IMatchInvitationRepository _invitationRepo;
    private readonly IFriendshipRepository      _friendshipRepo;
    private readonly IChildProfileRepository    _childProfileRepo;
    private readonly IEducationRepository       _educationRepo;
    private readonly ISocialNotifier            _socialNotifier;
    private readonly INotificationService       _notificationService;
    private readonly IMatchmakingService        _matchmakingService;
    private readonly IDailyUsageService         _dailyUsageService;

    /// <summary>Canlı yarış günlük kotası özellik anahtarı.</summary>
    private const string LiveMatchFeatureKey = "live_match";

    public MatchInvitationService(
        IMatchInvitationRepository  invitationRepo,
        IFriendshipRepository       friendshipRepo,
        IChildProfileRepository     childProfileRepo,
        IEducationRepository        educationRepo,
        ISocialNotifier             socialNotifier,
        INotificationService        notificationService,
        IMatchmakingService         matchmakingService,
        IDailyUsageService          dailyUsageService)
    {
        _invitationRepo      = invitationRepo;
        _friendshipRepo      = friendshipRepo;
        _childProfileRepo    = childProfileRepo;
        _educationRepo       = educationRepo;
        _socialNotifier      = socialNotifier;
        _notificationService = notificationService;
        _matchmakingService  = matchmakingService;
        _dailyUsageService   = dailyUsageService;
    }

    public async Task<MatchInvitationDto> SendInviteAsync(Guid inviterId, Guid inviteeId, Guid? subjectId)
    {
        // Arkadaş kontrolü
        var friendship = await _friendshipRepo.GetBetweenAsync(inviterId, inviteeId);
        if (friendship == null || friendship.Status != FriendshipStatus.Accepted)
            throw new InvalidOperationException("Yalnızca arkadaşlarınıza yarış daveti gönderebilirsiniz.");

        // Kota: davet gönderende (inviter) canlı yarış hakkı rezerve edilir. Limit
        // dolarsa ConsumeAsync DailyUsageLimitExceededException fırlatır → 429.
        // Davet reddi/iptali/süre dolumunda iade edilir.
        await ConsumeLiveMatchForChildAsync(inviterId);

        MatchInvitation invitation;
        try
        {
            invitation = await _invitationRepo.CreateAsync(inviterId, inviteeId, subjectId);
        }
        catch
        {
            await RefundLiveMatchForChildSafeAsync(inviterId);
            throw;
        }

        var inviter = await _childProfileRepo.GetByIdAsync(inviterId);
        var invitee = await _childProfileRepo.GetByIdAsync(inviteeId);
        var subjectName = subjectId.HasValue
            ? await GetSubjectNameAsync(subjectId.Value)
            : null;

        var dto = MapToDto(invitation, inviter?.Name ?? "", inviter?.AvatarImageUrl,
                           invitee?.Name ?? "", subjectName);

        // Gerçek zamanlı + push bildirim
        await _socialNotifier.NotifyMatchInviteAsync(inviteeId, dto);
        await _notificationService.SendMatchInviteNotificationAsync(inviteeId, inviter?.Name ?? "", invitation.Id);

        return dto;
    }

    public async Task<MatchInvitationDto> RespondAsync(Guid invitationId, Guid inviteeId, bool accept)
    {
        var inv = await _invitationRepo.GetByIdAsync(invitationId)
            ?? throw new InvalidOperationException("Davet bulunamadı.");

        if (inv.InviteeId != inviteeId)
            throw new UnauthorizedAccessException("Bu daveti yanıtlama yetkiniz yok.");

        if (inv.Status != MatchInvitationStatus.Pending)
            throw new InvalidOperationException("Davet zaten yanıtlanmış veya süresi dolmuş.");

        if (inv.ExpiresAt < DateTime.UtcNow)
        {
            await _invitationRepo.UpdateStatusAsync(invitationId, MatchInvitationStatus.Expired);
            throw new InvalidOperationException("Davet süresi dolmuş.");
        }

        Guid? matchSessionId = null;
        if (accept)
        {
            // Kota: kabul anında alıcı (invitee) için canlı yarış hakkı rezerve edilir.
            // Limit dolarsa 429; maç oluşturulamazsa alıcının hakkı iade edilir.
            await ConsumeLiveMatchForChildAsync(inv.InviteeId);
            try
            {
                var matchSession = await _matchmakingService.CreateDirectMatchAsync(
                    inv.InviterId, inv.InviteeId, inv.SubjectId);
                matchSessionId = matchSession.Id;
            }
            catch (Exception ex)
            {
                await RefundLiveMatchForChildSafeAsync(inv.InviteeId);
                throw new InvalidOperationException($"Maç oluşturulamadı: {ex.Message}");
            }
        }
        else
        {
            // Reddedildi → gönderenin (inviter) rezerve ettiği hakkı iade et.
            await RefundLiveMatchForChildSafeAsync(inv.InviterId);
        }

        var newStatus = accept ? MatchInvitationStatus.Accepted : MatchInvitationStatus.Declined;
        await _invitationRepo.UpdateStatusAsync(invitationId, newStatus, matchSessionId);
        inv.Status        = newStatus;
        inv.MatchSessionId = matchSessionId;

        var inviter = await _childProfileRepo.GetByIdAsync(inv.InviterId);
        var invitee = await _childProfileRepo.GetByIdAsync(inv.InviteeId);

        // Kabul edilirse → aynı inviter'ın diğer pending davetlerini expire et ve bildir
        if (accept)
        {
            var others = await _invitationRepo.GetOtherPendingByInviterAsync(inv.InviterId, invitationId);
            foreach (var other in others)
            {
                await _invitationRepo.UpdateStatusAsync(other.Id, MatchInvitationStatus.Expired);
                // Her expire edilen diğer davet için gönderenin rezervasyonunu iade et.
                await RefundLiveMatchForChildSafeAsync(inv.InviterId);
                await _socialNotifier.NotifyMatchInviteExpiredAsync(
                    other.InviteeId, other.Id, inviter?.Name ?? "");
            }
        }
        var subjectName = inv.SubjectId.HasValue
            ? await GetSubjectNameAsync(inv.SubjectId.Value)
            : null;

        var dto = MapToDto(inv, inviter?.Name ?? "", inviter?.AvatarImageUrl,
                           invitee?.Name ?? "", subjectName);

        // Gerçek zamanlı + push bildirim
        await _socialNotifier.NotifyMatchInviteResponseAsync(inv.InviterId, dto);
        await _notificationService.SendMatchInviteResponseNotificationAsync(
            inv.InviterId, invitee?.Name ?? "", accept);

        return dto;
    }

    public async Task<List<MatchInvitationDto>> GetPendingForInviteeAsync(Guid inviteeId)
    {
        var list = await _invitationRepo.GetPendingForInviteeAsync(inviteeId);
        var result = new List<MatchInvitationDto>();
        foreach (var inv in list)
        {
            var invitee     = await _childProfileRepo.GetByIdAsync(inv.InviteeId);
            var subjectName = inv.SubjectId.HasValue
                ? await GetSubjectNameAsync(inv.SubjectId.Value)
                : null;
            result.Add(MapToDto(inv, inv.Inviter.Name, inv.Inviter.AvatarImageUrl,
                                invitee?.Name ?? "", subjectName));
        }
        return result;
    }

    public async Task<List<MatchInvitationDto>> GetPendingForInviterAsync(Guid inviterId)
    {
        var list = await _invitationRepo.GetPendingForInviterAsync(inviterId);
        var result = new List<MatchInvitationDto>();
        foreach (var inv in list)
        {
            var inviter     = await _childProfileRepo.GetByIdAsync(inviterId);
            var subjectName = inv.SubjectId.HasValue
                ? await GetSubjectNameAsync(inv.SubjectId.Value)
                : null;
            result.Add(MapToDto(inv, inviter?.Name ?? "", inviter?.AvatarImageUrl,
                                inv.Invitee?.Name ?? "", subjectName));
        }
        return result;
    }

    public async Task ExpireOldAsync()
    {
        var expired = await _invitationRepo.ExpireOldAsync();
        // Süresi dolan her davet için gönderenin rezerve ettiği hakkı iade et.
        foreach (var inv in expired)
            await RefundLiveMatchForChildSafeAsync(inv.InviterId);
    }

    public async Task CancelAsync(Guid invitationId, Guid inviterId)
    {
        var inv = await _invitationRepo.GetByIdAsync(invitationId)
            ?? throw new InvalidOperationException("Davet bulunamadı.");

        if (inv.InviterId != inviterId)
            throw new UnauthorizedAccessException("Bu daveti iptal etme yetkiniz yok.");

        if (inv.Status != MatchInvitationStatus.Pending)
            return; // Zaten yanıtlanmış/süresi dolmuş, sessizce geç

        await _invitationRepo.UpdateStatusAsync(invitationId, MatchInvitationStatus.Expired);

        // İptal → gönderenin rezerve ettiği canlı yarış hakkını iade et.
        await RefundLiveMatchForChildSafeAsync(inv.InviterId);

        var inviter = await _childProfileRepo.GetByIdAsync(inv.InviterId);
        await _socialNotifier.NotifyMatchInviteExpiredAsync(
            inv.InviteeId, inv.Id, inviter?.Name ?? "");
    }

    // ── Helpers ─────────────────────────────────────────────────

    /// <summary>Çocuğun ebeveyni adına canlı yarış hakkını tüketir; limit dolarsa
    /// DailyUsageLimitExceededException fırlar (→ 429).</summary>
    private async Task ConsumeLiveMatchForChildAsync(Guid childId)
    {
        var userId = await _childProfileRepo.GetParentUserIdAsync(childId);
        if (userId.HasValue)
            await _dailyUsageService.ConsumeAsync(userId.Value, childId, LiveMatchFeatureKey);
    }

    /// <summary>Çocuğun ebeveyni adına rezerve edilen canlı yarış hakkını iade eder;
    /// telafi hatası akışı bozmaz.</summary>
    private async Task RefundLiveMatchForChildSafeAsync(Guid childId)
    {
        try
        {
            var userId = await _childProfileRepo.GetParentUserIdAsync(childId);
            if (userId.HasValue)
                await _dailyUsageService.RefundAsync(userId.Value, childId, LiveMatchFeatureKey);
        }
        catch
        {
            // Kota iadesi başarısız olsa bile davet akışını kesme.
        }
    }

    // ── Mapping ──────────────────────────────────────────────────────────────

    private static MatchInvitationDto MapToDto(
        Domain.Entities.MatchInvitation inv,
        string inviterName,
        string? inviterAvatar,
        string inviteeName,
        string? subjectName)
    {
        return new MatchInvitationDto
        {
            Id             = inv.Id,
            InviterId      = inv.InviterId,
            InviterName    = inviterName,
            InviterAvatar  = inviterAvatar,
            InviteeId      = inv.InviteeId,
            InviteeName    = inviteeName,
            SubjectId      = inv.SubjectId,
            SubjectName    = subjectName,
            Status         = (int)inv.Status,
            ExpiresAt      = inv.ExpiresAt,
            MatchSessionId = inv.MatchSessionId,
        };
    }

    private async Task<string?> GetSubjectNameAsync(Guid subjectId)
    {
        var subjects = await _educationRepo.GetAllSubjectsAsync(default);
        return subjects.FirstOrDefault(s => s.Id == subjectId)?.Name;
    }
}
