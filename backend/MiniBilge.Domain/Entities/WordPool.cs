using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>Kelime havuzu — hem elle eklenmiş hem AI üretimi kelimeler burada.</summary>
public class WordPool : BaseEntity
{
    public string  Word       { get; set; } = string.Empty;  // Büyük harf, 5 karakter
    public string  Language   { get; set; } = "tr";
    public string? Hint       { get; set; }
    public int     Difficulty { get; set; } = 2;              // 1=Kolay, 2=Orta, 3=Zor
    public string  Source     { get; set; } = "manual";       // "manual" | "ai_generated"
    public DateOnly? UsedOn   { get; set; }                   // null = hiç kullanılmadı
}
