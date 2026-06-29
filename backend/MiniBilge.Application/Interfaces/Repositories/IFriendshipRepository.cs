using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IFriendshipRepository
{
    /// <summary>Arkadaşlık isteği oluşturur (Pending).</summary>
    Task<Friendship> CreateAsync(Guid requesterId, Guid addresseeId);

    /// <summary>ID ile getirir.</summary>
    Task<Friendship?> GetByIdAsync(Guid id);

    /// <summary>İki kişi arasındaki kaydı getirir (her iki yönde).</summary>
    Task<Friendship?> GetBetweenAsync(Guid childA, Guid childB);

    /// <summary>Belirli bir çocuğun Accepted arkadaşlarını getirir.</summary>
    Task<List<Friendship>> GetAcceptedFriendsAsync(Guid childId);

    /// <summary>Belirli bir çocuğa gelen Pending istekleri getirir.</summary>
    Task<List<Friendship>> GetPendingRequestsAsync(Guid addresseeId);

    /// <summary>Durumu günceller (Accept / Decline / Block).</summary>
    Task UpdateStatusAsync(Guid id, FriendshipStatus status);

    /// <summary>Soft-delete ile arkadaşlığı siler.</summary>
    Task DeleteAsync(Guid id);
}
