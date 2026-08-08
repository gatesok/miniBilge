namespace MiniBilge.Application.DTOs.Card;

public class CollectibleCardDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Series { get; set; } = string.Empty;
    public string Rarity { get; set; } = string.Empty;
    public string ImageAsset { get; set; } = string.Empty;
    public int CardNumber { get; set; }
    public bool IsOwned { get; set; }
    public int OwnedCount { get; set; }
    public DateTime? FirstEarnedAt { get; set; }
    public bool IsPremiumExclusive { get; set; }
    public bool IsPremiumLocked { get; set; }
}

public class CardCollectionDto
{
    public int TotalCards { get; set; }
    public int OwnedCount { get; set; }
    public List<CollectibleCardDto> Cards { get; set; } = new();
    public int ShardBalance { get; set; }
    public int DailyRemaining { get; set; }
    public int DailyLimit { get; set; }
    public int PityRemaining { get; set; }
    public string EconomyStage { get; set; } = "starter";
}

public class CardDropDto
{
    public Guid CardId { get; set; }
    public string CardName { get; set; } = string.Empty;
    public string Rarity { get; set; } = string.Empty;
    public string ImageAsset { get; set; } = string.Empty;
    public bool IsNew { get; set; }
}
