namespace MiniBilge.Domain.Entities;

/// <summary>Her gün için seçilen kelimeyi tutar.</summary>
public class DailyWordAssignment
{
    public DateOnly  Date       { get; set; }
    public Guid      WordPoolId { get; set; }
    public string    Language   { get; set; } = "tr";
    public DateTime  CreatedAt  { get; set; }

    // Navigation
    public WordPool  WordPool   { get; set; } = null!;
}
