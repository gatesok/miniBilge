namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateEntertainmentRequest
{
    public string       TopicKey        { get; set; } = string.Empty;
    public string       Difficulty      { get; set; } = "Orta"; // "Kolay"|"Orta"|"Zor"
    public int          Count           { get; set; } = 10;
    /// <summary>DB-first: daha önce gösterilen soru ID'leri — tekrar önleme.</summary>
    public List<int>    ExcludeIds      { get; set; } = [];
    /// <summary>GPT fallback için metin bazlı tekrar önleme (geriye dönük uyumluluk).</summary>
    public List<string> AskedQuestions  { get; set; } = [];
    /// <summary>Tarih seed (her gün farklı context için).</summary>
    public string?      DateSeed        { get; set; }
    public string?      FocusTopic      { get; set; }
}

public class EntertainmentTopicDto
{
    public string Key   { get; set; } = string.Empty;
    public string Label { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
}

public class EntertainmentQuestionDto
{
    public int     Id            { get; set; }  // DB kaynaklı sorular için; AI için 0
    public string  QuestionText  { get; set; } = string.Empty;
    public string  OptionA       { get; set; } = string.Empty;
    public string  OptionB       { get; set; } = string.Empty;
    public string  OptionC       { get; set; } = string.Empty;
    public string  OptionD       { get; set; } = string.Empty;
    public string  CorrectAnswer { get; set; } = string.Empty; // "A"|"B"|"C"|"D"
    public string? Explanation   { get; set; }
}
