using MiniBilge.Application.DTOs.Experience;

namespace MiniBilge.Application.Interfaces.Services;

public interface IExperienceModeService
{
    Task<ExperienceModeDto?> GetAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<ExperienceModeDto?> UpdateAsync(
        Guid userId,
        string mode,
        CancellationToken cancellationToken = default);
}
