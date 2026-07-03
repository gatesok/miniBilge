using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class AiGeneratedQuestion : BaseEntity
{
    public Guid    ChildId       { get; set; }
    public string  SubjectName   { get; set; } = string.Empty;
    public string  TopicName     { get; set; } = string.Empty;
    public string  QuestionText  { get; set; } = string.Empty;
    /// <summary>JSON array: ["A şık", "B şık", "C şık", "D şık"]</summary>
    public string  OptionsJson   { get; set; } = string.Empty;
    public string  CorrectAnswer { get; set; } = string.Empty;
    public string? Explanation   { get; set; }
    public int     Difficulty    { get; set; } = 2;
    public DateTime? AnsweredAt  { get; set; }
    public bool?   IsCorrect     { get; set; }

    // Navigation
    public virtual ChildProfile Child { get; set; } = null!;
}
