using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Badge : BaseEntity
{
    public string Key { get; set; } = string.Empty;        // 'first_quiz', 'streak_7'
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;   // 'learning', 'speed', 'streak', 'match', 'special'
    public string Rarity { get; set; } = "bronze";         // 'bronze', 'silver', 'gold', 'legendary'
    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<ChildBadge> ChildBadges { get; set; } = new List<ChildBadge>();
}
