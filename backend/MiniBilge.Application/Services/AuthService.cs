using System.Security.Cryptography;
using System.Text;
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
    private readonly IPasswordResetTokenRepository _passwordResetTokenRepository;
    private readonly IJwtService _jwtService;
    private readonly IPasswordHasher _passwordHasher;
    private readonly IEmailService _emailService;

    public AuthService(
        IUserRepository userRepository,
        IRefreshTokenRepository refreshTokenRepository,
        IPasswordResetTokenRepository passwordResetTokenRepository,
        IJwtService jwtService,
        IPasswordHasher passwordHasher,
        IEmailService emailService)
    {
        _userRepository = userRepository;
        _refreshTokenRepository = refreshTokenRepository;
        _passwordResetTokenRepository = passwordResetTokenRepository;
        _jwtService = jwtService;
        _passwordHasher = passwordHasher;
        _emailService = emailService;
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
            ExpiresAt = DateTime.UtcNow.AddDays(365)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(365),
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
            ExpiresAt = DateTime.UtcNow.AddDays(365)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = accessToken,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(365),
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
            ExpiresAt = DateTime.UtcNow.AddDays(365)
        }, cancellationToken);

        return new AuthResponse
        {
            AccessToken = newAccessToken,
            RefreshToken = newRefreshToken,
            ExpiresAt = DateTime.UtcNow.AddDays(365),
            User = MapToUserDto(user)
        };
    }

    public async Task LogoutAsync(string refreshToken, CancellationToken cancellationToken = default)
    {
        await _refreshTokenRepository.RevokeAsync(refreshToken, cancellationToken);
    }

    private UserDto MapToUserDto(User user)
    {
        var premiumSubscription = user.Subscriptions
            .Where(s =>
                (s.Status == SubscriptionStatus.Active || s.Status == SubscriptionStatus.GracePeriod) &&
                s.ExpiresAt > DateTime.UtcNow &&
                !s.IsDeleted)
            .OrderByDescending(s => s.ExpiresAt)
            .FirstOrDefault();
        return new UserDto
        {
            Id = user.Id,
            Email = user.Email,
            Role = user.Role.ToString(),
            CanUseOnlineSpeech = user.CanUseOnlineSpeech,
            IsPremium = premiumSubscription != null,
            PremiumExpiresAt = premiumSubscription?.ExpiresAt,
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

    public async Task ForgotPasswordAsync(ForgotPasswordRequest request, CancellationToken cancellationToken = default)
    {
        // Kullanıcı bulunamazsa güvenlik nedeniyle hata fırlatma; sessizce dön
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken);
        if (user == null) return;

        // Önceki tokenları geçersiz kıl
        await _passwordResetTokenRepository.InvalidateAllByUserIdAsync(user.Id, cancellationToken);

        // 6 haneli kriptografik rastgele kod üret
        var code = RandomNumberGenerator.GetInt32(100000, 999999).ToString();
        var codeHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(code)));

        await _passwordResetTokenRepository.CreateAsync(new PasswordResetToken
        {
            UserId = user.Id,
            CodeHash = codeHash,
            ExpiresAt = DateTime.UtcNow.AddMinutes(15),
        }, cancellationToken);

        await _emailService.SendPasswordResetCodeAsync(user.Email, code, cancellationToken);
    }

    public async Task ResetPasswordAsync(ResetPasswordRequest request, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByEmailAsync(request.Email, cancellationToken)
            ?? throw new Exception("Kullanıcı bulunamadı");

        var resetToken = await _passwordResetTokenRepository.GetValidByUserIdAsync(user.Id, cancellationToken)
            ?? throw new Exception("Geçerli bir sıfırlama kodu bulunamadı veya kodun süresi doldu");

        var inputHash = Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(request.Code)));
        if (!string.Equals(resetToken.CodeHash, inputHash, StringComparison.OrdinalIgnoreCase))
            throw new Exception("Girilen kod hatalı");

        user.PasswordHash = _passwordHasher.HashPassword(request.NewPassword);
        await _userRepository.UpdateAsync(user, cancellationToken);

        await _passwordResetTokenRepository.MarkAsUsedAsync(resetToken.Id, cancellationToken);

        // Aktif tüm refresh tokenları iptal et
        await _refreshTokenRepository.RevokeAllByUserIdAsync(user.Id, cancellationToken);
    }

    public async Task DeleteAccountAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        var user = await _userRepository.GetByIdAsync(userId, cancellationToken)
            ?? throw new Exception("Kullanıcı bulunamadı");

        // Tüm refresh tokenları iptal et
        await _refreshTokenRepository.RevokeAllByUserIdAsync(userId, cancellationToken);

        // Soft delete
        await _userRepository.DeleteAsync(userId, cancellationToken);
    }
}
