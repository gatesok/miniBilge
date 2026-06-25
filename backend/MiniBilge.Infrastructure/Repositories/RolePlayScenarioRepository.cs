using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class RolePlayScenarioRepository : IRolePlayScenarioRepository
{
    private readonly ApplicationDbContext _context;

    public RolePlayScenarioRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<RolePlayScenario>> GetByLevelAsync(string level)
        => await _context.RolePlayScenarios
            .Where(s => s.Level == level && s.IsActive)
            .OrderBy(s => s.DisplayOrder)
            .ToListAsync();

    public async Task<RolePlayScenario?> GetByKeyAsync(string key)
        => await _context.RolePlayScenarios
            .FirstOrDefaultAsync(s => s.Key == key && s.IsActive);
}
