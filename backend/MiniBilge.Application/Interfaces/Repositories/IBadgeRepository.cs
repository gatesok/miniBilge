using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IBadgeRepository
{
    Task<List<Badge>> GetAllAsync();
    Task<Badge?> GetByKeyAsync(string key);
    Task<List<ChildBadge>> GetEarnedByChildAsync(Guid childProfileId);
    Task<bool> HasEarnedAsync(Guid childProfileId, string badgeKey);
    Task AwardAsync(Guid childProfileId, Guid badgeId);
}
