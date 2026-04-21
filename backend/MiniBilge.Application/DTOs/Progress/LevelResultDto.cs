namespace MiniBilge.Application.DTOs.Progress;

public class LevelResultDto
{
    public Guid Id { get; set; }
    public Guid ChildId { get; set; }
    public Guid LevelId { get; set; }
    public int Score { get; set; }
    public int Stars { get; set; }
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public decimal SuccessPercentage { get; set; }
    public bool IsUnlocked { get; set; }
    public DateTime? CompletedAt { get; set; }
}
