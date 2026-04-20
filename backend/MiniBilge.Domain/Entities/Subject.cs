using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Subject : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public ICollection<Topic> Topics { get; set; } = new List<Topic>();
}
