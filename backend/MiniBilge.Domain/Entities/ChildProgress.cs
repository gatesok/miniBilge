using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class ChildProgress : BaseEntity
{
    public Guid ChildId { get; set; }
    public int TotalScore { get; set; } = 0;
    public int TotalStars { get; set; } = 0;
    public int CompletedLevelsCount { get; set; } = 0;
    
    // Navigation
    public ChildProfile Child { get; set; } = null!;
}
