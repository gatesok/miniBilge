namespace MiniBilge.Application.DTOs.Progress;

public class ChildProgressDto
{
    public Guid Id { get; set; }
    public Guid ChildId { get; set; }
    public int TotalScore { get; set; }
    public int TotalStars { get; set; }
    public int CompletedLevelsCount { get; set; }
}
