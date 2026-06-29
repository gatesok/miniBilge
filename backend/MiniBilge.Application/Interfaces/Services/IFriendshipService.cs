using MiniBilge.Application.DTOs.Friendship;

namespace MiniBilge.Application.Interfaces.Services;

public interface IFriendshipService
{
    /// <summary>FriendCode ile arama — profil önizlemesi + mevcut arkadaşlık durumu.</summary>
    Task<FriendSearchResultDto?> SearchByCodeAsync(Guid requesterId, string friendCode);

    /// <summary>Arkadaşlık isteği gönder.</summary>
    Task<FriendDto> SendRequestAsync(Guid requesterId, string friendCode);

    /// <summary>Gelen isteği kabul veya reddet.</summary>
    Task RespondAsync(Guid friendshipId, Guid addresseeId, bool accept);

    /// <summary>Arkadaşlığı kaldır (soft-delete).</summary>
    Task RemoveAsync(Guid friendshipId, Guid childId);

    /// <summary>Kişiyi engelle.</summary>
    Task BlockAsync(Guid friendshipId, Guid blockerId);

    /// <summary>Kabul edilmiş arkadaş listesini getir.</summary>
    Task<List<FriendDto>> GetFriendsAsync(Guid childId);

    /// <summary>Bekleyen gelen istekleri getir.</summary>
    Task<List<FriendDto>> GetPendingRequestsAsync(Guid childId);
}
