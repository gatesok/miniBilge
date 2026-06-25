using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IRolePlayScenarioRepository
{
    Task<List<RolePlayScenario>> GetByLevelAsync(string level);
    Task<RolePlayScenario?> GetByKeyAsync(string key);
}
