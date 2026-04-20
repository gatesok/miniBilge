using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Topic : BaseEntity
{
    public Guid SubjectId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public Subject Subject { get; set; } = null!;
    public ICollection<Level> Levels { get; set; } = new List<Level>();
}
