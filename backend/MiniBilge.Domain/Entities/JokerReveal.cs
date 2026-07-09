namespace MiniBilge.Domain.Entities;

/// <summary>Joker hakkıyla açılan bir harf pozisyonu.</summary>
public class JokerReveal
{
    public int    Position { get; set; }  // 0-bazlı pozisyon
    public string Letter   { get; set; } = string.Empty;
}
