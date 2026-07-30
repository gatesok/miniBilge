namespace MiniBilge.Domain.Entities;

public class CardEconomyEvent
{
    public Guid Id { get; set; }
    public Guid ChildProfileId { get; set; }
    public Guid? CardId { get; set; }
    public string Source { get; set; } = string.Empty;
    public string Stage { get; set; } = string.Empty;
    public string Outcome { get; set; } = string.Empty;
    public double DropRate { get; set; }
    public bool WasGuaranteed { get; set; }
    public bool WasDuplicate { get; set; }
    public int ShardsAwarded { get; set; }
    public string? IdempotencyKey { get; set; }
    public DateTime CreatedAt { get; set; }
}
