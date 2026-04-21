namespace MiniBilge.Application.DTOs.Progress;

public class SaveProgressRequest
{
    public Guid ChildId { get; set; }
    public Guid LevelId { get; set; }
    public int Score { get; set; }
    public int Stars { get; set; }
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public decimal SuccessPercentage { get; set; }
}
