using System.Security.Claims;

namespace MiniBilge.Application.Interfaces.Services;

public interface IJwtService
{
    string GenerateAccessToken(Guid userId, string email, string role, bool isTeacher = false);
    string GenerateRefreshToken();
    ClaimsPrincipal? ValidateToken(string token);
}
