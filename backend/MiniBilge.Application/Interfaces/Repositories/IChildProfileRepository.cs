using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IChildProfileRepository
{
    Task<ChildProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    /// <summary>Verilen çocuk profilinin bağlı olduğu ebeveyn kullanıcı id'sini döner (kota işlemleri için).</summary>
    Task<Guid?> GetParentUserIdAsync(Guid childId, CancellationToken cancellationToken = default);
    Task<List<ChildProfile>> GetByParentIdAsync(Guid parentId, CancellationToken cancellationToken = default);
    Task<List<ChildProfile>> GetAllAsync(CancellationToken cancellationToken = default);

    /// <summary>Yetişkin (GradeLevel.Adult) profillerin id'leri — turnuva bildirimleri için.</summary>
    Task<List<Guid>> GetAdultIdsAsync(CancellationToken cancellationToken = default);
    /// <summary>Sistemdeki toplam (silinmemiş) profil sayısı. early_bird için kullanılır.</summary>
    Task<int> CountAsync(CancellationToken cancellationToken = default);
    Task<ChildProfile?> GetByFriendCodeAsync(string friendCode, CancellationToken cancellationToken = default);
    Task<bool> FriendCodeExistsAsync(string friendCode, CancellationToken cancellationToken = default);
    Task<ChildProfile> CreateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default);
    Task UpdateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
