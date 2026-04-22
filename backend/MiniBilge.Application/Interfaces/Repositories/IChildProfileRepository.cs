using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IChildProfileRepository
{
    Task<ChildProfile?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<List<ChildProfile>> GetByParentIdAsync(Guid parentId, CancellationToken cancellationToken = default);
    Task<List<ChildProfile>> GetAllAsync(CancellationToken cancellationToken = default);
    Task<ChildProfile> CreateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default);
    Task UpdateAsync(ChildProfile childProfile, CancellationToken cancellationToken = default);
    Task DeleteAsync(Guid id, CancellationToken cancellationToken = default);
}
