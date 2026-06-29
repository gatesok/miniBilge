using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class Friendship : BaseEntity
{
    public Guid RequesterId  { get; set; }
    public Guid AddresseeId  { get; set; }
    public FriendshipStatus Status { get; set; } = FriendshipStatus.Pending;

    // Navigation
    public ChildProfile Requester  { get; set; } = null!;
    public ChildProfile Addressee  { get; set; } = null!;
}
