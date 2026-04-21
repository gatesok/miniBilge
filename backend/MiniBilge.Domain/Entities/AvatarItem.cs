using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class AvatarItem : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public ItemType ItemType { get; set; }
    public int PointCost { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    public ICollection<ChildOwnedItem> OwnedByChildren { get; set; } = new List<ChildOwnedItem>();
    public ICollection<ChildEquippedItem> EquippedByChildren { get; set; } = new List<ChildEquippedItem>();
}
