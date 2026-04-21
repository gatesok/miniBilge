using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Avatar : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    public ICollection<ChildProfile> ChildProfiles { get; set; } = new List<ChildProfile>();
}
