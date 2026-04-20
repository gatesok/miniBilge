using System.Security.Claims;

namespace MiniBilge.Application.Interfaces.Services;

public interface IJwtService
{
    string GenerateAccessToken(Guid userId, string email, string role);
    string GenerateRefreshToken();
    ClaimsPrincipal? ValidateToken(string token);
}
