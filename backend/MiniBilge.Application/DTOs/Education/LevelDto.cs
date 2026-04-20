namespace MiniBilge.Application.DTOs.Education;

public class LevelDto
{
    public Guid Id { get; set; }
    public Guid TopicId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Difficulty { get; set; }
    public int DisplayOrder { get; set; }
    public int MinCorrectToPass { get; set; }
    public bool IsActive { get; set; }
}
