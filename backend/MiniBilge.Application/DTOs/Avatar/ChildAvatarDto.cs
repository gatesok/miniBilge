namespace MiniBilge.Application.DTOs.Avatar;

public class ChildAvatarDto
{
    public Guid ChildProfileId { get; set; }
    public string ChildName { get; set; } = string.Empty;
    public AvatarDto? Avatar { get; set; }
    public List<EquippedItemDto> EquippedItems { get; set; } = new();
    public int TotalPoints { get; set; }
}

public class EquippedItemDto
{
    public Guid ItemId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int ItemType { get; set; }
    public string ItemTypeName { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public DateTime EquippedAt { get; set; }
}
