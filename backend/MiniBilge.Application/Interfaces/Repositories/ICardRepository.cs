using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface ICardRepository
{
    Task<List<CollectibleCard>> GetAllActiveAsync();
    Task<List<ChildCard>> GetCollectionByChildAsync(Guid childProfileId);
    Task<ChildCard?> GetChildCardAsync(Guid childProfileId, Guid cardId);
    Task AddOrIncrementAsync(Guid childProfileId, Guid cardId, string source);
}
