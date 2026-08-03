using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Bir çocuk profilinin belirli bir güne ait "Bugünkü Planım" birleşik yolculuğu.
/// (ChildProfileId, PlanDate) tekildir → gün başına tek plan.
/// </summary>
public class DailyPlan : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public DateOnly PlanDate { get; set; }
    public DailyPlanStatus Status { get; set; } = DailyPlanStatus.Pending;

    // Planın nasıl üretildiği: "standard" | "personalized" | "fallback".
    public string Source { get; set; } = "standard";
    public bool IsPremiumPersonalized { get; set; }

    public int TotalItems { get; set; }
    public int CompletedItems { get; set; }
    public DateTime? CompletedAt { get; set; }

    // Tamamlanma ödülü (yıldız + leaderboard puanı) — RewardGranted idempotency sağlar.
    public int RewardStars { get; set; }
    public int RewardPoints { get; set; }
    public bool RewardGranted { get; set; }

    public ChildProfile ChildProfile { get; set; } = null!;
    public ICollection<DailyPlanItem> Items { get; set; } = new List<DailyPlanItem>();
}
