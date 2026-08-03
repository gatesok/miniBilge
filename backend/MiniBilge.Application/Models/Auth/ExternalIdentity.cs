using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Models.Auth;

public sealed record ExternalIdentity(
    ExternalAuthProvider Provider,
    string Subject,
    string Email,
    bool EmailVerified,
    string? FirstName,
    string? LastName,
    bool IsPrivateEmail);
