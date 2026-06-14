using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class Topic : BaseEntity
{
    public Guid SubjectId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public GradeLevel GradeLevel { get; set; } = GradeLevel.Grade1;

    // Navigation properties
    public Subject Subject { get; set; } = null!;
    public ICollection<Level> Levels { get; set; } = new List<Level>();
}
