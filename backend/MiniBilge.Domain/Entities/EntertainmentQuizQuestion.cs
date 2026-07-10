namespace MiniBilge.Domain.Entities;

/// <summary>Eğlence quiz (çoktan seçmeli) soru havuzu — entertainment_quiz tablosu.</summary>
public class EntertainmentQuizQuestion
{
    public int     Id            { get; set; }
    public string  CategoryKey   { get; set; } = string.Empty;  // 'spor','genel_kultur',...
    public int     Difficulty    { get; set; }                  // 1=Kolay 2=Orta 3=Zor
    public string  QuestionText  { get; set; } = string.Empty;
    public string  OptionA       { get; set; } = string.Empty;
    public string  OptionB       { get; set; } = string.Empty;
    public string  OptionC       { get; set; } = string.Empty;
    public string  OptionD       { get; set; } = string.Empty;
    public string  CorrectAnswer { get; set; } = string.Empty;  // "A"|"B"|"C"|"D"
    public string? Explanation   { get; set; }
    public string  Language      { get; set; } = "tr";
    public bool    IsActive      { get; set; } = true;
    public DateTime CreatedAt    { get; set; }
}
