using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IUserExternalLoginRepository
{
    Task<UserExternalLogin?> GetByProviderSubjectAsync(
        ExternalAuthProvider provider,
        string providerSubject,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<UserExternalLogin>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task<UserExternalLogin?> GetByUserAndProviderAsync(
        Guid userId,
        ExternalAuthProvider provider,
        CancellationToken cancellationToken = default);

    Task<UserExternalLogin> CreateAsync(
        UserExternalLogin externalLogin,
        CancellationToken cancellationToken = default);

    Task UpdateLastLoginAsync(
        Guid externalLoginId,
        DateTime lastLoginAt,
        CancellationToken cancellationToken = default);

    Task DeleteAsync(
        Guid externalLoginId,
        CancellationToken cancellationToken = default);
}
