namespace MiniBilge.Application.Interfaces.Repositories;

public interface IDeviceTokenRepository
{
    Task UpsertAsync(Guid childProfileId, string token, string platform);
    Task<IEnumerable<string>> GetTokensByChildIdAsync(Guid childProfileId);
    Task<IEnumerable<string>> GetTokensByChildIdsAsync(IEnumerable<Guid> childProfileIds);
    Task<IEnumerable<(Guid ChildProfileId, string Token)>> GetAllActiveTokensAsync();
}
