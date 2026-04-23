namespace MiniBilge.Application.DTOs.ParentReport;

public class WeakTopicDto
{
    public Guid TopicId { get; set; }
    public string TopicName { get; set; } = string.Empty;
    public string SubjectName { get; set; } = string.Empty;
    public int TotalAttempts { get; set; }
    public int CorrectAttempts { get; set; }
    public decimal SuccessRate { get; set; } // 0.0 - 1.0
}
