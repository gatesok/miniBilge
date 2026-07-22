namespace MiniBilge.Application.DTOs.AdaptiveQuiz;

/// <summary>Çocuğun zayıf olduğu bir konuyu temsil eder.</summary>
public class WeakTopicDto
{
    public string  SubjectName          { get; set; } = string.Empty;
    public string  TopicName            { get; set; } = string.Empty;
    public double  AvgSuccessPercent    { get; set; }
    public int     AttemptCount         { get; set; }
    public int     SuggestedDifficulty  { get; set; }
    /// <summary>İngilizce konular için CEFR seviyesi (A1..C2). Matematik için null.</summary>
    public string? EnglishLevel         { get; set; }
    /// <summary>Matematik konular için sınıf (1-4). İngilizce için 0.</summary>
    public int     GradeLevel           { get; set; }
    /// <summary>AI testinde son 5 soruda 5/5 yapıldıysa true.</summary>
    public bool    IsMastered           { get; set; }
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
    public string CorrectAnswer  { get; set; } = string.Empty;
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
    /// <summary>İngilizce için CEFR seviyesi — prompt kalitesini artırır.</summary>
    public string? EnglishLevel { get; set; }
}

/// <summary>Çocuğun cevabını kaydetmek için.</summary>
public class SubmitAdaptiveAnswerRequest
{
    public Guid   QuestionId   { get; set; }
    public string GivenAnswer  { get; set; } = string.Empty;
}

/// <summary>Quiz tamamlama ödülleri request.</summary>
public class AwardAdaptiveQuizRequest
{
    public int    CorrectCount  { get; set; }
    public int    TotalCount    { get; set; }
    /// <summary>Konuyu mastery kontrolü için kullanılır.</summary>
    public string TopicName     { get; set; } = string.Empty;
    /// <summary>Challenge ödülünde puan/oyun sayısının ikinci kez yazılmasını engeller.</summary>
    public bool SkipAdultCompetitionStats { get; set; }
}

/// <summary>Kazanılan ödüller.</summary>
public class AdaptiveQuizRewardDto
{
    public int    StarsEarned  { get; set; }
    public int    BadgeCount   { get; set; }
    public bool   CardDropped  { get; set; }
    public string? CardName    { get; set; }
    public string? CardRarity  { get; set; }
    public string? CardImageAsset { get; set; }
    public Guid?  CardId       { get; set; }
    public bool   CardIsNew    { get; set; }
    public bool   TopicMastered { get; set; }
}
