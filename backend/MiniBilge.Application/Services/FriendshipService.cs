using MiniBilge.Application.DTOs.Friendship;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class FriendshipService : IFriendshipService
{
    private readonly IFriendshipRepository      _friendshipRepo;
    private readonly IChildProfileRepository    _childProfileRepo;
    private readonly ISocialNotifier            _socialNotifier;
    private readonly INotificationService       _notificationService;
    private readonly IEntitlementService        _entitlementService;

    public FriendshipService(
        IFriendshipRepository   friendshipRepo,
        IChildProfileRepository childProfileRepo,
        ISocialNotifier         socialNotifier,
        INotificationService    notificationService,
        IEntitlementService     entitlementService)
    {
        _friendshipRepo      = friendshipRepo;
        _childProfileRepo    = childProfileRepo;
        _socialNotifier      = socialNotifier;
        _notificationService = notificationService;
        _entitlementService = entitlementService;
    }

    public async Task<FriendSearchResultDto?> SearchByCodeAsync(Guid requesterId, string friendCode)
    {
        var target = await _childProfileRepo.GetByFriendCodeAsync(friendCode.Trim().ToUpper());
        if (target == null) return null;
        if (target.Id == requesterId)
            throw new InvalidOperationException("Kendi kodunuzla arama yapamazsınız.");

        var existing = await _friendshipRepo.GetBetweenAsync(requesterId, target.Id);

        return new FriendSearchResultDto
        {
            ChildId          = target.Id,
            Name             = target.Name,
            AvatarImageUrl   = target.AvatarImageUrl,
            FriendCode       = target.FriendCode,
            FriendshipStatus = (existing != null && !existing.IsDeleted) ? (int)existing.Status : null,
        };
    }

    public async Task<FriendDto> SendRequestAsync(
        Guid requesterId,
        string friendCode,
        bool enforceFreeFriendLimit = false)
    {
        await EnsureFriendLimitAsync(requesterId, enforceFreeFriendLimit);
        var target = await _childProfileRepo.GetByFriendCodeAsync(friendCode.Trim().ToUpper())
            ?? throw new InvalidOperationException("Bu kod ile kayıtlı profil bulunamadı.");

        if (target.Id == requesterId)
            throw new InvalidOperationException("Kendinize arkadaşlık isteği gönderemezsiniz.");

        var existing = await _friendshipRepo.GetBetweenAsync(requesterId, target.Id);

        Friendship friendship;
        if (existing != null && (existing.IsDeleted || existing.Status == FriendshipStatus.Blocked))
        {
            // Silinmiş veya reddedilmiş kaydı Pending'e döndür
            existing.IsDeleted   = false;
            existing.Status      = FriendshipStatus.Pending;
            existing.RequesterId = requesterId;
            existing.AddresseeId = target.Id;
            existing.UpdatedAt   = DateTime.UtcNow;
            await _friendshipRepo.SaveAsync();
            friendship = existing;
        }
        else if (existing != null)
        {
            // Aktif Pending veya Accepted kayıt var
            throw new InvalidOperationException("Bu kişiyle zaten bir arkadaşlık kaydı var.");
        }
        else
        {
            friendship = await _friendshipRepo.CreateAsync(requesterId, target.Id);
        }

        // target zaten bellekte — navigation property'leri yüklemeden DTO oluştur
        var dto = new FriendDto
        {
            FriendshipId   = friendship.Id,
            ChildId        = target.Id,
            Name           = target.Name,
            DisplayName    = target.Name,
            AvatarImageUrl = target.AvatarImageUrl,
            AvatarKey      = target.AvatarImageUrl,
            FriendCode     = target.FriendCode,
            Status         = (int)FriendshipStatus.Pending,
            IsRequester    = true,
        };

        // Gerçek zamanlı bildirim — başarısız olsa da isteği döndür
        try
        {
            var requester = await _childProfileRepo.GetByIdAsync(requesterId);
            if (requester != null)
            {
                var requesterDto = new FriendDto
                {
                    FriendshipId   = friendship.Id,
                    ChildId        = requester.Id,
                    Name           = requester.Name,
                    DisplayName    = requester.Name,
                    AvatarKey      = requester.AvatarImageUrl,
                    AvatarImageUrl = requester.AvatarImageUrl,
                    FriendCode     = requester.FriendCode,
                    Status         = (int)FriendshipStatus.Pending,
                    IsRequester    = true,
                };
                await _socialNotifier.NotifyFriendRequestAsync(target.Id, requesterDto, friendship.Id);
                await _notificationService.SendFriendRequestNotificationAsync(target.Id, requester.Name);
            }
        }
        catch
        {
            // Bildirim hatası ana akışı bozmamalı
        }

        return dto;
    }

    public async Task RespondAsync(
        Guid friendshipId,
        Guid addresseeId,
        bool accept,
        bool enforceFreeFriendLimit = false)
    {
        var f = await _friendshipRepo.GetByIdAsync(friendshipId)
            ?? throw new InvalidOperationException("Arkadaşlık isteği bulunamadı.");

        if (f.AddresseeId != addresseeId)
            throw new UnauthorizedAccessException("Bu isteği yanıtlama yetkiniz yok.");

        if (f.Status != FriendshipStatus.Pending)
            throw new InvalidOperationException("İstek zaten yanıtlanmış.");

        if (accept)
        {
            await EnsureFriendLimitAsync(f.RequesterId, enforceFreeFriendLimit);
            await EnsureFriendLimitAsync(f.AddresseeId, enforceFreeFriendLimit);
        }

        await _friendshipRepo.UpdateStatusAsync(
            friendshipId,
            accept ? FriendshipStatus.Accepted : FriendshipStatus.Blocked);
    }

    public async Task RemoveAsync(Guid friendshipId, Guid childId)
    {
        var f = await _friendshipRepo.GetByIdAsync(friendshipId)
            ?? throw new InvalidOperationException("Arkadaşlık kaydı bulunamadı.");

        if (f.RequesterId != childId && f.AddresseeId != childId)
            throw new UnauthorizedAccessException("Bu kaydı silme yetkiniz yok.");

        await _friendshipRepo.DeleteAsync(friendshipId);
    }

    public async Task BlockAsync(Guid friendshipId, Guid blockerId)
    {
        var f = await _friendshipRepo.GetByIdAsync(friendshipId)
            ?? throw new InvalidOperationException("Arkadaşlık kaydı bulunamadı.");

        if (f.RequesterId != blockerId && f.AddresseeId != blockerId)
            throw new UnauthorizedAccessException("Bu kaydı güncelleme yetkiniz yok.");

        await _friendshipRepo.UpdateStatusAsync(friendshipId, FriendshipStatus.Blocked);
    }

    public async Task<List<FriendDto>> GetFriendsAsync(Guid childId)
    {
        var list = await _friendshipRepo.GetAcceptedFriendsAsync(childId);
        return list.Select(f => MapToDto(f, childId)).ToList();
    }

    public async Task<List<FriendDto>> GetPendingRequestsAsync(Guid childId)
    {
        var list = await _friendshipRepo.GetPendingRequestsAsync(childId);
        return list.Select(f => MapToDto(f, childId)).ToList();
    }

    // ── Helpers ──────────────────────────────────────────────────────────────

    private async Task EnsureFriendLimitAsync(Guid childId, bool enforce)
    {
        if (!enforce) return;

        var userId = await _childProfileRepo.GetParentUserIdAsync(childId);
        if (!userId.HasValue || (await _entitlementService.GetForUserAsync(userId.Value)).IsPremium)
            return;

        var friends = await _friendshipRepo.GetAcceptedFriendsAsync(childId);
        if (friends.Count >= 3)
            throw new InvalidOperationException(
                "Ücretsiz üyelikte en fazla 3 arkadaş ekleyebilirsin. Daha fazlası için Premium üyelik gerekli.");
    }

    private static FriendDto MapToDto(Friendship f, Guid callerChildId)
    {
        var isRequester = f.RequesterId == callerChildId;
        var friend      = isRequester ? f.Addressee : f.Requester;

        return new FriendDto
        {
            FriendshipId   = f.Id,
            ChildId        = friend.Id,
            Name           = friend.Name,
            DisplayName    = friend.Name,
            AvatarImageUrl = friend.AvatarImageUrl,
            AvatarKey      = friend.AvatarImageUrl,
            FriendCode     = friend.FriendCode,
            Status         = (int)f.Status,
            IsRequester    = isRequester,
        };
    }
}
