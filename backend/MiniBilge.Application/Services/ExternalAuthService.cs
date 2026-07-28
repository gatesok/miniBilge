using MiniBilge.Application.DTOs.Auth;
using MiniBilge.Application.DTOs.Profile;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Application.Models.Auth;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class ExternalAuthService : IExternalAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IUserExternalLoginRepository _externalLoginRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtService _jwtService;
    private readonly IGoogleIdentityVerifier _googleIdentityVerifier;
    private readonly IAppleIdentityVerifier _appleIdentityVerifier;

    public ExternalAuthService(
        IUserRepository userRepository,
        IUserExternalLoginRepository externalLoginRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtService jwtService,
        IGoogleIdentityVerifier googleIdentityVerifier,
        IAppleIdentityVerifier appleIdentityVerifier)
    {
        _userRepository = userRepository;
        _externalLoginRepository = externalLoginRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtService = jwtService;
        _googleIdentityVerifier = googleIdentityVerifier;
        _appleIdentityVerifier = appleIdentityVerifier;
    }

    public async Task<AuthResponse> LoginWithGoogleAsync(
        ExternalLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var identity = await _googleIdentityVerifier.VerifyAsync(
            request.IdToken,
            cancellationToken);

        return await LoginAsync(identity, cancellationToken);
    }

    public async Task<AuthResponse> LoginWithAppleAsync(
        AppleLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var verifiedIdentity = await _appleIdentityVerifier.VerifyAsync(
            request.IdentityToken,
            request.Nonce,
            cancellationToken);
        var identity = verifiedIdentity with
        {
            FirstName = request.FirstName,
            LastName = request.LastName
        };

        return await LoginAsync(identity, cancellationToken);
    }

    public async Task LinkGoogleAsync(
        Guid userId,
        ExternalLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var identity = await _googleIdentityVerifier.VerifyAsync(
            request.IdToken,
            cancellationToken);
        await LinkAsync(userId, identity, cancellationToken);
    }

    public async Task LinkAppleAsync(
        Guid userId,
        AppleLoginRequest request,
        CancellationToken cancellationToken = default)
    {
        var identity = await _appleIdentityVerifier.VerifyAsync(
            request.IdentityToken,
            request.Nonce,
            cancellationToken);
        await LinkAsync(userId, identity, cancellationToken);
    }

    public async Task<ExternalLoginStatusResponse> GetStatusAsync(
        Guid userId,
        CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken)
            ?? throw new InvalidOperationException("Kullanıcı bulunamadı");
        var externalLogins = await _externalLoginRepository.GetByUserIdAsync(
            userId,
            cancellationToken);

        return new ExternalLoginStatusResponse
        {
            HasPassword = !string.IsNullOrEmpty(user.PasswordHash),
            Providers = externalLogins
                .Select(login => login.Provider.ToString())
                .ToArray()
        };
    }

    public async Task UnlinkAsync(
        Guid userId,
        string provider,
        CancellationToken cancellationToken = default)
    {
        if (!Enum.TryParse<ExternalAuthProvider>(
                provider,
                true,
                out var parsedProvider))
        {
            throw new InvalidOperationException("Desteklenmeyen giriş sağlayıcısı");
        }

        var user = await _userRepository.GetByIdAsync(userId, cancellationToken)
            ?? throw new InvalidOperationException("Kullanıcı bulunamadı");
        var externalLogins = await _externalLoginRepository.GetByUserIdAsync(
            userId,
            cancellationToken);
        var loginToRemove = externalLogins.FirstOrDefault(
            login => login.Provider == parsedProvider);

        if (loginToRemove is null)
        {
            return;
        }

        var hasPassword = !string.IsNullOrEmpty(user.PasswordHash);
        if (!hasPassword && externalLogins.Count == 1)
        {
            throw new InvalidOperationException(
                "Hesabınızda en az bir giriş yöntemi kalmalıdır");
        }

        await _externalLoginRepository.DeleteAsync(
            loginToRemove.Id,
            cancellationToken);
    }

    private async Task<AuthResponse> LoginAsync(
        ExternalIdentity identity,
        CancellationToken cancellationToken)
    {
        var externalLogin = await _externalLoginRepository.GetByProviderSubjectAsync(
            identity.Provider,
            identity.Subject,
            cancellationToken);

        User user;
        if (externalLogin is not null)
        {
            user = externalLogin.User;
            var loginTime = DateTime.UtcNow;
            user.LastLoginAt = loginTime;
            await _userRepository.UpdateAsync(user, cancellationToken);
            await _externalLoginRepository.UpdateLastLoginAsync(
                externalLogin.Id,
                loginTime,
                cancellationToken);
        }
        else
        {
            var existingUser = await _userRepository.GetByEmailWithProfileAsync(
                identity.Email,
                cancellationToken);

            if (existingUser is not null)
            {
                throw new InvalidOperationException(
                    "Bu e-posta ile kayıtlı bir MiniBilge hesabı var. Önce e-posta ve şifrenizle giriş yaparak Google hesabınızı bağlayın.");
            }

            user = new User
            {
                Email = identity.Email,
                PasswordHash = null,
                Role = UserRole.Parent,
                IsEmailConfirmed = identity.EmailVerified,
                LastLoginAt = DateTime.UtcNow,
                ParentProfile = new ParentProfile
                {
                    FirstName = NormalizeName(identity.FirstName, "MiniBilge"),
                    LastName = NormalizeName(identity.LastName, "Kullanıcısı")
                }
            };

            await _userRepository.CreateAsync(user, cancellationToken);

            externalLogin = new UserExternalLogin
            {
                UserId = user.Id,
                Provider = identity.Provider,
                ProviderSubject = identity.Subject,
                ProviderEmail = identity.Email,
                IsPrivateEmail = identity.IsPrivateEmail,
                LastLoginAt = user.LastLoginAt
            };

            await _externalLoginRepository.CreateAsync(externalLogin, cancellationToken);
        }

        return await CreateSessionAsync(user, cancellationToken);
    }

    private async Task LinkAsync(
        Guid userId,
        ExternalIdentity identity,
        CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken)
            ?? throw new InvalidOperationException("Kullanıcı bulunamadı");

        var subjectLogin = await _externalLoginRepository
            .GetByProviderSubjectAsync(
                identity.Provider,
                identity.Subject,
                cancellationToken);

        if (subjectLogin is not null)
        {
            if (subjectLogin.UserId == userId)
            {
                return;
            }

            throw new InvalidOperationException(
                "Bu hesap başka bir MiniBilge kullanıcısına bağlı");
        }

        var currentProviderLogin = await _externalLoginRepository
            .GetByUserAndProviderAsync(
                userId,
                identity.Provider,
                cancellationToken);

        if (currentProviderLogin is not null)
        {
            throw new InvalidOperationException(
                "Bu MiniBilge hesabına farklı bir sağlayıcı hesabı zaten bağlı");
        }

        await _externalLoginRepository.CreateAsync(
            new UserExternalLogin
            {
                UserId = user.Id,
                Provider = identity.Provider,
                ProviderSubject = identity.Subject,
                ProviderEmail = identity.Email,
                IsPrivateEmail = identity.IsPrivateEmail,
                LastLoginAt = DateTime.UtcNow
            },
            cancellationToken);
    }

    private async Task<AuthResponse> CreateSessionAsync(
        User user,
        CancellationToken cancellationToken)
    {
        var accessToken = _jwtService.GenerateAccessToken(
            user.Id,
            user.Email,
            user.Role.ToString());
        var refreshToken = _jwtService.GenerateRefreshToken();
        var expiresAt = DateTime.UtcNow.AddDays(365);

        await _refreshTokenRepository.CreateAsync(
            new RefreshToken
            {
                UserId = user.Id,
                Token = refreshToken,
                ExpiresAt = expiresAt
            },
            cancellationToken);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = expiresAt,
            User = MapToUserDto(user)
        };
    }

    private static UserDto MapToUserDto(User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            Role = user.Role.ToString(),
            CanUseOnlineSpeech = user.CanUseOnlineSpeech,
            ParentProfile = user.ParentProfile is null
                ? null
                : new ParentProfileDto
                {
                    Id = user.ParentProfile.Id,
                    FirstName = user.ParentProfile.FirstName,
                    LastName = user.ParentProfile.LastName,
                    PhoneNumber = user.ParentProfile.PhoneNumber,
                    ChildrenCount = 0
                }
        };
    }

    private static string NormalizeName(string? value, string fallback)
    {
        return string.IsNullOrWhiteSpace(value) ? fallback : value.Trim();
    }
}
