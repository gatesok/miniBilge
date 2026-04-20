using MiniBilge.Application.DTOs.Auth;
using MiniBilge.Application.DTOs.Profile;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class AuthService : IAuthService
{
    private readonly IUserRepository _userRepository;
    private readonly IRefreshTokenRepository _refreshTokenRepository;
    private readonly IJwtService _jwtService;
    private readonly IPasswordHasher _passwordHasher;

    public AuthService(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IJwtService jwtService,
        IPasswordHasher passwordHasher)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _jwtService = jwtService;
        _passwordHasher = passwordHasher;
    }

    public async Task<AuthResponse> RegisterAsync(RegisterRequest request, CancellationToken cancellationToken = default)
    {
        if (await _userRepository.ExistsByEmailAsync(request.Email, cancellationToken))
        {
            throw new Exception("Bu email adresi zaten kullanımda");
        }

        var user = new User
        {
            Email = request.Email,
            PasswordHash = _passwordHasher.HashPassword(request.Password),
            Role = UserRole.Parent,
            IsEmailConfirmed = false,
            ParentProfile = new ParentProfile
            {
                FirstName = request.FirstName,
                LastName = request.LastName,
                PhoneNumber = request.PhoneNumber
            }
        };

        await _userRepository.CreateAsync(user, cancellationToken);

        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role.ToString());
        var refreshToken = _jwtService.GenerateRefreshToken();

        await _refreshTokenRepository.CreateAsync(new RefreshToken
        {
            UserId = user.Id,
            Token = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddHours(1),
            User = MapToUserDto(user)
        };
    }

    public async Task<AuthResponse> LoginAsync(LoginRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByEmailWithProfileAsync(request.Email, cancellationToken);

        if (user == null || !_passwordHasher.VerifyPassword(request.Password, user.PasswordHash))
        {
            throw new Exception("Email veya şifre hatalı");
        }

        user.LastLoginAt = DateTime.UtcNow;
        await _userRepository.UpdateAsync(user, cancellationToken);

        var accessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role.ToString());
        var refreshToken = _jwtService.GenerateRefreshToken();

        await _refreshTokenRepository.CreateAsync(new RefreshToken
        {
            UserId = user.Id,
            Token = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddHours(1),
            User = MapToUserDto(user)
        };
    }

    public async Task<AuthResponse> RefreshTokenAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        var storedToken = await _refreshTokenRepository.GetByTokenAsync(refreshToken, cancellationToken);

        if (storedToken == null || storedToken.ExpiresAt < DateTime.UtcNow)
        {
            throw new Exception("Geçersiz veya süresi dolmuş refresh token");
        }

        await _refreshTokenRepository.RevokeAsync(refreshToken, cancellationToken);

        var user = storedToken.User;
        var newAccessToken = _jwtService.GenerateAccessToken(user.Id, user.Email, user.Role.ToString());
        var newRefreshToken = _jwtService.GenerateRefreshToken();

        await _refreshTokenRepository.CreateAsync(new RefreshToken
        {
            UserId = user.Id,
            Token = newRefreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(7)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken,
            ExpiresAt = DateTime.UtcNow.AddHours(1),
            User = MapToUserDto(user)
        };
    }

    public async Task LogoutAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        await _refreshTokenRepository.RevokeAsync(refreshToken, cancellationToken);
    }

    private UserDto MapToUserDto(User user)
    {
        return new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            Role = user.Role.ToString(),
            ParentProfile = user.ParentProfile != null ? new ParentProfileDto
            {
                Id = user.ParentProfile.Id,
                FirstName = user.ParentProfile.FirstName,
                LastName = user.ParentProfile.LastName,
                PhoneNumber = user.ParentProfile.PhoneNumber,
                ChildrenCount = 0
            } : null
        };
    }
}
