using MiniBilge.Application.DTOs.Profile;

namespace MiniBilge.Application.Interfaces.Services;

public interface IChildProfileService
{
    Task<List<ChildProfileDto>> GetChildrenByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task<ChildProfileDto> GetChildByIdAsync(Guid id, CancellationToken cancellationToken = default);
    Task<ChildProfileDto> CreateChildAsync(Guid userId, CreateChildProfileRequest request, CancellationToken cancellationToken = default);
    Task<ChildProfileDto> UpdateChildAsync(Guid id, CreateChildProfileRequest request, CancellationToken cancellationToken = default);
    Task DeleteChildAsync(Guid id, CancellationToken cancellationToken = default);
}
