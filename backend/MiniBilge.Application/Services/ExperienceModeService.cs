using MiniBilge.Application.DTOs.Experience;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public sealed class ExperienceModeService : IExperienceModeService
{
    private readonly IUserRepository _userRepository;

    public ExperienceModeService(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<ExperienceModeDto?> GetAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        return user is null ? null : Map(user.ExperienceMode);
    }

    public async Task<ExperienceModeDto?> UpdateAsync(
        Guid userId,
        string mode,
        CancellationToken cancellationToken = default)
    {
        if (!Enum.TryParse<ExperienceMode>(mode?.Trim(), ignoreCase: true, out var parsedMode) ||
            !Enum.IsDefined(parsedMode))
        {
            throw new ArgumentException("Geçerli modlar: Child, Adult, Family.", nameof(mode));
        }

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken);
        if (user is null)
        {
            return null;
        }

        if (user.ExperienceMode != parsedMode)
        {
            user.ExperienceMode = parsedMode;
            await _userRepository.UpdateAsync(user, cancellationToken);
        }

        return Map(user.ExperienceMode);
    }

    private static ExperienceModeDto Map(ExperienceMode mode) => new()
    {
        Mode = mode.ToString()
    };
}
