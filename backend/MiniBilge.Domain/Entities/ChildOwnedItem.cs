using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class ChildOwnedItem : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public Guid ItemId { get; set; }
    public DateTime PurchasedAt { get; set; }
    
    // Navigation properties
    public ChildProfile ChildProfile { get; set; } = null!;
    public AvatarItem Item { get; set; } = null!;
}
