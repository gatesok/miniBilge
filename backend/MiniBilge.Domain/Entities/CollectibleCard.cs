using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class CollectibleCard : BaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Series { get; set; } = string.Empty;     // 'animals', 'heroes', 'legends'
    public string Rarity { get; set; } = "common";         // 'common', 'rare', 'epic', 'legendary'
    public string ImageAsset { get; set; } = string.Empty; // 'assets/cards/owl.png' — Kenney.nl
    public int CardNumber { get; set; }                    // Koleksiyon numarası
    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<ChildCard> ChildCards { get; set; } = new List<ChildCard>();
}
