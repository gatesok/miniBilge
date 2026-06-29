namespace MiniBilge.Application.DTOs.Friendship;

public class FriendDto
{
    public Guid   FriendshipId   { get; set; }
    public Guid   ChildId        { get; set; }
    public string Name           { get; set; } = string.Empty;
    /// <summary>Alias for Name — used by SocialNotifier.</summary>
    public string DisplayName    { get; set; } = string.Empty;
    public string? AvatarImageUrl { get; set; }
    /// <summary>Alias for AvatarImageUrl — used by SocialNotifier.</summary>
    public string? AvatarKey     { get; set; }
    public string FriendCode     { get; set; } = string.Empty;
    /// <summary>0=Pending, 1=Accepted, 2=Blocked</summary>
    public int    Status         { get; set; }
    /// <summary>Bu çocuk isteği gönderen miydi?</summary>
    public bool   IsRequester    { get; set; }
}

public class FriendSearchResultDto
{
    public Guid   ChildId      { get; set; }
    public string Name         { get; set; } = string.Empty;
    public string? AvatarImageUrl { get; set; }
    public string FriendCode   { get; set; } = string.Empty;
    /// <summary>null = daha arkadaş değil, değer = mevcut durum</summary>
    public int?   FriendshipStatus { get; set; }
}

public class SendFriendRequestDto
{
    public Guid   RequesterId  { get; set; }
    public string FriendCode   { get; set; } = string.Empty;
}

public class RespondFriendRequestDto
{
    public Guid AddresseeId { get; set; }
    public bool Accept      { get; set; }
}
