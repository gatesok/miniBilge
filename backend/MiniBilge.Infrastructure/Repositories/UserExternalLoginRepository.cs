using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class UserExternalLoginRepository : IUserExternalLoginRepository
{
    private readonly ApplicationDbContext _context;

    public UserExternalLoginRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public Task<UserExternalLogin?> GetByProviderSubjectAsync(
        ExternalAuthProvider provider,
        string providerSubject,
        CancellationToken cancellationToken = default)
    {
        return _context.UserExternalLogins
            .Include(login => login.User)
                .ThenInclude(user => user.ParentProfile)
            .FirstOrDefaultAsync(
                login => login.Provider == provider
                    && login.ProviderSubject == providerSubject
                    && !login.IsDeleted
                    && !login.User.IsDeleted,
                cancellationToken);
    }

    public async Task<IReadOnlyList<UserExternalLogin>> GetByUserIdAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        return await _context.UserExternalLogins
            .Where(login => login.UserId == userId && !login.IsDeleted)
            .OrderBy(login => login.Provider)
            .ToListAsync(cancellationToken);
    }

    public Task<UserExternalLogin?> GetByUserAndProviderAsync(
        Guid userId,
        ExternalAuthProvider provider,
        CancellationToken cancellationToken = default)
    {
        return _context.UserExternalLogins.FirstOrDefaultAsync(
            login => login.UserId == userId
                && login.Provider == provider
                && !login.IsDeleted,
            cancellationToken);
    }

    public async Task<UserExternalLogin> CreateAsync(
        UserExternalLogin externalLogin,
        CancellationToken cancellationToken = default)
    {
        await _context.UserExternalLogins.AddAsync(externalLogin, cancellationToken);
        await _context.SaveChangesAsync(cancellationToken);
        return externalLogin;
    }

    public async Task UpdateLastLoginAsync(
        Guid externalLoginId,
        DateTime lastLoginAt,
        CancellationToken cancellationToken = default)
    {
        var externalLogin = await _context.UserExternalLogins
            .FirstOrDefaultAsync(
                login => login.Id == externalLoginId && !login.IsDeleted,
                cancellationToken);

        if (externalLogin is null)
        {
            return;
        }

        externalLogin.LastLoginAt = lastLoginAt;
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(
        Guid externalLoginId,
        CancellationToken cancellationToken = default)
    {
        var externalLogin = await _context.UserExternalLogins
            .FirstOrDefaultAsync(
                login => login.Id == externalLoginId,
                cancellationToken);

        if (externalLogin is null)
        {
            return;
        }

        _context.UserExternalLogins.Remove(externalLogin);
        await _context.SaveChangesAsync(cancellationToken);
    }
}
