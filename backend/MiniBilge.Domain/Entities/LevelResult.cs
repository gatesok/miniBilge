using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class LevelResult : BaseEntity
{
    public Guid ChildId { get; set; }
    public Guid LevelId { get; set; }
    public int Score { get; set; }
    public int Stars { get; set; } // 0-3
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public decimal SuccessPercentage { get; set; }
    public bool IsUnlocked { get; set; } = false;
    public DateTime? CompletedAt { get; set; }
    /// <summary>Quiz'in toplam tamamlanma süresi (saniye) — Hız Treni rozeti için.</summary>
    public int? DurationSeconds { get; set; }
    /// <summary>En hızlı doğru cevabın süresi (saniye) — Şimşek rozeti için.</summary>
    public int? FastestCorrectAnswerSeconds { get; set; }
    
    // Navigation
    public ChildProfile Child { get; set; } = null!;
    public Level Level { get; set; } = null!;
}
