namespace MiniBilge.Application.DTOs.Progress;

public class SaveAnswerAttemptRequest
{
    public Guid ChildId { get; set; }
    public Guid QuestionId { get; set; }
    public string SubmittedAnswer { get; set; } = string.Empty;
    public bool IsCorrect { get; set; }
    public int? TimeTakenSeconds { get; set; }
}
