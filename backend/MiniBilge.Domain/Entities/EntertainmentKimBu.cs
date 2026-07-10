namespace MiniBilge.Domain.Entities;

/// <summary>Kim Bu? içerik havuzu — entertainment_kim_bu tablosu.</summary>
public class EntertainmentKimBu
{
    public int          Id            { get; set; }
    public int          Difficulty    { get; set; }  // 1=Kolay 2=Orta 3=Zor
    public string       Subject       { get; set; } = string.Empty;  // Doğru cevap
    public List<string> Hints         { get; set; } = [];            // 5 ipucu (JSONB)
    public List<string> Options       { get; set; } = [];            // 4 şık (JSONB)
    public string       CorrectAnswer { get; set; } = string.Empty;
    public string       Language      { get; set; } = "tr";
    public bool         IsActive      { get; set; } = true;
    public DateTime     CreatedAt     { get; set; }
}
