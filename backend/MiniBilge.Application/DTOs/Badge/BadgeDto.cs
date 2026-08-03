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

    /// <summary>Bu rozetin, sorgulanan profil türü (child/adult) için geçerli olup olmadığı.</summary>
    public bool IsApplicableToProfile { get; set; } = true;

    /// <summary>Kilitli rozetler için sayısal ilerleme; hesaplanamıyorsa null.</summary>
    public BadgeProgressDto? Progress { get; set; }
}

/// <summary>Kilitli bir rozetin hedefe doğru ilerlemesi (örn. 3/5, %80).</summary>
public class BadgeProgressDto
{
    public int Current { get; set; }
    public int Target { get; set; }

    /// <summary>"count" | "categories" | "streak" | "days" | "percent"</summary>
    public string Unit { get; set; } = "count";
}

public class BadgeCollectionDto
{
    public int TotalBadges { get; set; }
    public int EarnedCount { get; set; }
    public List<BadgeDto> Badges { get; set; } = new();
}
