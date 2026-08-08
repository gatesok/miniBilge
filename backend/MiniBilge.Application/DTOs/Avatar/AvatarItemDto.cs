namespace MiniBilge.Application.DTOs.Avatar;

public class AvatarItemDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int ItemType { get; set; }
    public string ItemTypeName { get; set; } = string.Empty;
    public int PointCost { get; set; }
    public string ImageUrl { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public bool IsOwned { get; set; }
    public bool IsEquipped { get; set; }
}
