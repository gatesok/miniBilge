namespace MiniBilge.Application.DTOs.Education;

public class SubmitAnswerRequest
{
    public Guid QuestionId { get; set; }
    public string UserAnswer { get; set; } = string.Empty;
}
