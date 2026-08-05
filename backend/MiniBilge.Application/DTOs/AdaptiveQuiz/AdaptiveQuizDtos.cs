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
    /// <summary>İstemcinin her tamamlanan quiz için ürettiği benzersiz anahtar.</summary>
    public string? RewardEventId { get; set; }
    /// <summary>
    /// Dolu ise bu ödül bir eğlence quizidir; verilen kategori anahtarıyla (ör. 'genel_kultur',
    /// 'kelime', 'kim_bu') eğlence istatistikleri ve rozetleri işlenir.
    /// </summary>
    public string? FunCategoryKey { get; set; }

    /// <summary>Zorluk seviyesi (Kolay/Orta/Zor) — turnuva puan çarpanı için.</summary>
    public string? Difficulty { get; set; }

    /// <summary>
    /// True ise kart düşme ihtimali çok düşük bir geçitle sınırlanır (ör. oyuncu kendi
    /// profil seviyesinin altında bir seviyede oynuyorsa kart farmlamayı önlemek için).
    /// </summary>
    public bool DampenCardDrop { get; set; }

    /// <summary>İstemcinin ölçtüğü oyun süresi (saniye). Haftalık çalışma süresine eklenir.</summary>
    public int? DurationSeconds { get; set; }
}

/// <summary>Kazanılan ödüller.</summary>
public class AdaptiveQuizRewardDto
{
    public int    StarsEarned  { get; set; }
    public int    BadgeCount   { get; set; }
    /// <summary>Kazanılan rozet anahtarları (istemci zengin overlay gösterir).</summary>
    public List<string> EarnedBadges { get; set; } = new();
    public bool   CardDropped  { get; set; }
    public string? CardName    { get; set; }
    public string? CardRarity  { get; set; }
    public string? CardImageAsset { get; set; }
    public Guid?  CardId       { get; set; }
    public bool   CardIsNew    { get; set; }
    public int    CardShardsAwarded { get; set; }
    public int    CardShardBalance { get; set; }
    public int    CardDailyRemaining { get; set; }
    public int    CardPityRemaining { get; set; }
    public string CardEconomyStage { get; set; } = "starter";
    public bool   CardWasGuaranteed { get; set; }
    public bool   TopicMastered { get; set; }
}
