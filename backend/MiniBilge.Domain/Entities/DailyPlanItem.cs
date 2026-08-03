using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Günlük plandaki tek bir aktivite maddesi (ör. 5 matematik sorusu, 5 kelime tekrarı).
/// </summary>
public class DailyPlanItem : BaseEntity
{
    public Guid DailyPlanId { get; set; }
    public int Order { get; set; }

    // Aktivite türü: "math" | "english_vocab" | "flashcard" | "entertainment".
    public string ActivityType { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;

    // Mobilin ilgili aktiviteye yönlenmesi için ipucu (route/deeplink anahtarı).
    public string? RouteKey { get; set; }
    public int TargetCount { get; set; }

    // P6: "Neden bu aktivite?" açıklaması (kişiselleştirilmiş planda doldurulur, standartta null).
    public string? Note { get; set; }

    public bool IsCompleted { get; set; }
    public DateTime? CompletedAt { get; set; }

    public DailyPlan DailyPlan { get; set; } = null!;
}
