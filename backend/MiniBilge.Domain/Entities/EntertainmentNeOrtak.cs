namespace MiniBilge.Domain.Entities;

/// <summary>Ne Ortak? içerik havuzu — entertainment_ne_ortak tablosu.</summary>
public class EntertainmentNeOrtak
{
    public int          Id            { get; set; }
    public int          Difficulty    { get; set; }  // 1=Kolay 2=Orta 3=Zor
    public List<string> Clues         { get; set; } = [];            // 4 ipucu (JSONB)
    public string       Connection    { get; set; } = string.Empty;  // Ortak bağlantı (doğru cevap)
    public List<string> Options       { get; set; } = [];            // 4 şık (JSONB)
    public string       CorrectAnswer { get; set; } = string.Empty;
    public string?      Explanation   { get; set; }
    public string       Language      { get; set; } = "tr";
    public bool         IsActive      { get; set; } = true;
    public DateTime     CreatedAt     { get; set; }
}
