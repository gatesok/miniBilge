using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class MatchInvitation : BaseEntity
{
    public Guid    InviterId      { get; set; }
    public Guid    InviteeId      { get; set; }
    public Guid?   SubjectId      { get; set; }
    public MatchInvitationStatus Status { get; set; } = MatchInvitationStatus.Pending;
    public Guid?   MatchSessionId { get; set; }
    public DateTime ExpiresAt     { get; set; }

    // Navigation
    public ChildProfile  Inviter       { get; set; } = null!;
    public ChildProfile  Invitee       { get; set; } = null!;
    public MatchSession? MatchSession  { get; set; }
}
