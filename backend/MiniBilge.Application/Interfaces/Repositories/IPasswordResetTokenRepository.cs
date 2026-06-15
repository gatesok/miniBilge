using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IPasswordResetTokenRepository
{
    Task<PasswordResetToken> CreateAsync(PasswordResetToken token, CancellationToken cancellationToken = default);
    Task<PasswordResetToken?> GetValidByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
    Task MarkAsUsedAsync(Guid tokenId, CancellationToken cancellationToken = default);
    Task InvalidateAllByUserIdAsync(Guid userId, CancellationToken cancellationToken = default);
}
