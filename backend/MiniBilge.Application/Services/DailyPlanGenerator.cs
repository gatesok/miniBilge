using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

/// <summary>
/// "Bugünkü Planım" V1 standart plan üreticisi. İlk şablon: 5 matematik sorusu +
/// 5 İngilizce kelime tekrarı. Sınıf/İngilizce seviyesi maddelerin başlığını ve
/// hedef sayısını belirler.
/// </summary>
public sealed class DailyPlanGenerator : IDailyPlanGenerator
{
    private const string StandardSource = "standard";

    // Planın tamamı bitirildiğinde verilen günlük tamamlanma ödülü.
    private const int DailyCompletionRewardStars = 5;
    private const int DailyCompletionRewardPoints = 50;

    public DailyPlan Generate(ChildProfile profile, DateOnly planDate)
    {
        ArgumentNullException.ThrowIfNull(profile);

        var plan = new DailyPlan
        {
            Id = Guid.NewGuid(),
            ChildProfileId = profile.Id,
            PlanDate = planDate,
            Status = DailyPlanStatus.Pending,
            Source = StandardSource,
            IsPremiumPersonalized = false,
            RewardStars = DailyCompletionRewardStars,
            RewardPoints = DailyCompletionRewardPoints,
        };

        AddItem(plan, order: 1, activityType: "math",
            title: "Günün Matematik Alıştırması", targetCount: MathQuestionCount(profile.GradeLevel));
        AddItem(plan, order: 2, activityType: "english_vocab",
            title: "Günün İngilizce Kelimeleri", targetCount: VocabWordCount(profile.EnglishLevel));

        plan.TotalItems = plan.Items.Count;
        return plan;
    }

    public DailyPlan GenerateFallback(ChildProfile profile, DateOnly planDate)
    {
        ArgumentNullException.ThrowIfNull(profile);

        var plan = new DailyPlan
        {
            Id = Guid.NewGuid(),
            ChildProfileId = profile.Id,
            PlanDate = planDate,
            Status = DailyPlanStatus.Pending,
            Source = "fallback",
            IsPremiumPersonalized = false,
            RewardStars = DailyCompletionRewardStars,
            RewardPoints = DailyCompletionRewardPoints,
        };

        // Dış içeriğe bağımlı olmayan, her zaman sunulabilen güvenli maddeler.
        AddItem(plan, order: 1, activityType: "flashcard",
            title: "Kelime Kartı Tekrarı", targetCount: 5);
        AddItem(plan, order: 2, activityType: "entertainment",
            title: "Kısa Eğlence Aktivitesi", targetCount: 1);

        plan.TotalItems = plan.Items.Count;
        return plan;
    }

    private static void AddItem(DailyPlan plan, int order, string activityType, string title, int targetCount)
    {
        plan.Items.Add(new DailyPlanItem
        {
            Id = Guid.NewGuid(),
            DailyPlanId = plan.Id,
            Order = order,
            ActivityType = activityType,
            Title = title,
            TargetCount = targetCount,
        });
    }

    private static int MathQuestionCount(GradeLevel grade) => grade == GradeLevel.PreSchool ? 3 : 5;

    private static int VocabWordCount(EnglishLevel? level) => level is null or EnglishLevel.A1 ? 5 : 6;
}
