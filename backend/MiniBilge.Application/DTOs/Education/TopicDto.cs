namespace MiniBilge.Application.DTOs.Education;

public class TopicDto
{
    public Guid Id { get; set; }
    public Guid SubjectId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; }
    public int GradeLevel { get; set; }
}
