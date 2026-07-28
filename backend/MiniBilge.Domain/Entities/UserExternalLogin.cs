using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class UserExternalLogin : BaseEntity
{
    public Guid UserId { get; set; }
    public ExternalAuthProvider Provider { get; set; }
    public string ProviderSubject { get; set; } = string.Empty;
    public string? ProviderEmail { get; set; }
    public bool IsPrivateEmail { get; set; }
    public DateTime? LastLoginAt { get; set; }

    public User User { get; set; } = null!;
}
