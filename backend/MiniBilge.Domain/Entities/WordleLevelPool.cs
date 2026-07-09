using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>Kelime Seviye oyunu için önceden hazırlanmış kelime havuzu.</summary>
public class WordleLevelPool : BaseEntity
{
    public string Word       { get; set; } = string.Empty;
    public string Hint       { get; set; } = string.Empty;
    public int    WordLength { get; set; }
    public int    Difficulty { get; set; } = 2; // 1=Kolay, 2=Orta, 3=Zor
    public string Language   { get; set; } = "tr";
    public int    UsedCount  { get; set; } = 0;
}
