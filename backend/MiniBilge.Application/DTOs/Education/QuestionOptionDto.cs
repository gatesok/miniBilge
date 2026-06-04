namespace MiniBilge.Application.DTOs.Education;

public class QuestionOptionDto
{
    public Guid Id { get; set; }
    public string OptionText { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
    public bool HasLatex { get; set; } = false;
}
