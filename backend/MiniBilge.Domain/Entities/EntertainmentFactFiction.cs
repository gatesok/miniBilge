namespace MiniBilge.Domain.Entities;

/// <summary>Gerçek mi Uydurma mı içerik havuzu — entertainment_fact_fiction tablosu.</summary>
public class EntertainmentFactFiction
{
    public int      Id          { get; set; }
    public int      Difficulty  { get; set; }  // 1=Kolay 2=Orta 3=Zor
    public string   Statement   { get; set; } = string.Empty;
    public bool     IsReal      { get; set; }
    public string   Explanation { get; set; } = string.Empty;
    public string   Language    { get; set; } = "tr";
    public bool     IsActive    { get; set; } = true;
    public DateTime CreatedAt   { get; set; }
}
