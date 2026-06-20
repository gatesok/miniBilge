namespace MiniBilge.Application.DTOs.Badge;

public class BadgeDto
{
    public Guid Id { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
    public string Category { get; set; } = string.Empty;
    public string Rarity { get; set; } = string.Empty;
    public bool IsEarned { get; set; }
    public DateTime? EarnedAt { get; set; }
}

public class BadgeCollectionDto
{
    public int TotalBadges { get; set; }
    public int EarnedCount { get; set; }
    public List<BadgeDto> Badges { get; set; } = new();
}
