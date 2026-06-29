namespace MiniBilge.Application.DTOs.Match;

public class MatchInvitationDto
{
    public Guid    Id            { get; set; }
    public Guid    InviterId     { get; set; }
    public string  InviterName   { get; set; } = string.Empty;
    public string? InviterAvatar { get; set; }
    public Guid    InviteeId     { get; set; }
    public string  InviteeName   { get; set; } = string.Empty;
    public Guid?   SubjectId     { get; set; }
    public string? SubjectName   { get; set; }
    /// <summary>0=Pending, 1=Accepted, 2=Declined, 3=Expired</summary>
    public int     Status        { get; set; }
    public DateTime ExpiresAt    { get; set; }
    public Guid?   MatchSessionId { get; set; }
}

public class SendMatchInviteDto
{
    public Guid  InviterId  { get; set; }
    public Guid  InviteeId  { get; set; }
    public Guid? SubjectId  { get; set; }
}

public class RespondMatchInviteDto
{
    public Guid InviteeId { get; set; }
    public bool Accept    { get; set; }
}
