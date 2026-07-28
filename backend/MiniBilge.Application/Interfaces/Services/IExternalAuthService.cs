using MiniBilge.Application.DTOs.Auth;

namespace MiniBilge.Application.Interfaces.Services;

public interface IExternalAuthService
{
    Task<AuthResponse> LoginWithGoogleAsync(
        ExternalLoginRequest request,
        CancellationToken cancellationToken = default);

    Task<AuthResponse> LoginWithAppleAsync(
        AppleLoginRequest request,
        CancellationToken cancellationToken = default);

    Task LinkGoogleAsync(
        Guid userId,
        ExternalLoginRequest request,
        CancellationToken cancellationToken = default);

    Task LinkAppleAsync(
        Guid userId,
        AppleLoginRequest request,
        CancellationToken cancellationToken = default);

    Task<ExternalLoginStatusResponse> GetStatusAsync(
        Guid userId,
        CancellationToken cancellationToken = default);

    Task UnlinkAsync(
        Guid userId,
        string provider,
        CancellationToken cancellationToken = default);
}
