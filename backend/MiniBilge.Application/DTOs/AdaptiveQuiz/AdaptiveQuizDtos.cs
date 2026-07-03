namespace MiniBilge.Application.DTOs.AdaptiveQuiz;

/// <summary>Çocuğun zayıf olduğu bir konuyu temsil eder.</summary>
public class WeakTopicDto
{
    public string SubjectName       { get; set; } = string.Empty;
    public string TopicName         { get; set; } = string.Empty;
    public double AvgSuccessPercent { get; set; }
    public int    AttemptCount      { get; set; }
    public int    SuggestedDifficulty { get; set; } // 1-3
}

/// <summary>AI tarafından üretilen tek bir soru.</summary>
public class AdaptiveQuestionDto
{
    public Guid   Id             { get; set; }
    public string QuestionText   { get; set; } = string.Empty;
    public string OptionA        { get; set; } = string.Empty;
    public string OptionB        { get; set; } = string.Empty;
    public string OptionC        { get; set; } = string.Empty;
    public string OptionD        { get; set; } = string.Empty;
    public string CorrectAnswer  { get; set; } = string.Empty; // "A"|"B"|"C"|"D"
    public string? Explanation   { get; set; }
    public string SubjectName    { get; set; } = string.Empty;
    public string TopicName      { get; set; } = string.Empty;
    public int    Difficulty     { get; set; }
}

/// <summary>Generate endpoint request body.</summary>
public class GenerateAdaptiveQuestionsRequest
{
    public string TopicName    { get; set; } = string.Empty;
    public string SubjectName  { get; set; } = string.Empty;
    public int    GradeLevel   { get; set; }
    public int    Difficulty   { get; set; } = 2;
    public int    Count        { get; set; } = 5;
}

/// <summary>Çocuğun cevabını kaydetmek için.</summary>
public class SubmitAdaptiveAnswerRequest
{
    public Guid   QuestionId   { get; set; }
    public string GivenAnswer  { get; set; } = string.Empty; // "A"|"B"|"C"|"D"
}
