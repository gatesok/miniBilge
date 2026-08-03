using MiniBilge.Application.DTOs.ParentReport;
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
    private const string PersonalizedSource = "personalized";

    // Kişiselleştirilmiş plan madde başlığı 120 karakter sınırını aşmasın diye konu adı kırpılır.
    private const int MaxTopicNameLength = 60;

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

    public DailyPlan GeneratePersonalized(
        ChildProfile profile, DateOnly planDate, IReadOnlyList<WeakTopicDto> weakTopics)
    {
        ArgumentNullException.ThrowIfNull(profile);
        ArgumentNullException.ThrowIfNull(weakTopics);

        var plan = new DailyPlan
        {
            Id = Guid.NewGuid(),
            ChildProfileId = profile.Id,
            PlanDate = planDate,
            Status = DailyPlanStatus.Pending,
            Source = PersonalizedSource,
            IsPremiumPersonalized = true,
            RewardStars = DailyCompletionRewardStars,
            RewardPoints = DailyCompletionRewardPoints,
        };

        // weakTopics başarı oranına göre artan sıralı gelir (en zayıf ilk).
        var mathTopic = weakTopics.FirstOrDefault(t => IsMathSubject(t.SubjectName));
        var englishTopic = weakTopics.FirstOrDefault(t => IsEnglishSubject(t.SubjectName));
        var weakest = weakTopics.Count > 0 ? weakTopics[0] : null;

        // Madde 1: matematik — varsa en zayıf matematik konusuna odaklan.
        AddItem(plan, order: 1, activityType: "math",
            title: mathTopic is not null
                ? $"{TrimTopic(mathTopic.TopicName)} – Matematik Tekrarı"
                : "Sana Özel Matematik Alıştırması",
            targetCount: MathQuestionCount(profile.GradeLevel),
            routeKey: mathTopic is not null ? TopicRoute(mathTopic.TopicId) : null,
            note: WeakTopicNote(mathTopic));

        // Madde 2: İngilizce — varsa en zayıf İngilizce konusuna odaklan.
        AddItem(plan, order: 2, activityType: "english_vocab",
            title: englishTopic is not null
                ? $"{TrimTopic(englishTopic.TopicName)} – Kelime Tekrarı"
                : "Sana Özel İngilizce Kelimeleri",
            targetCount: VocabWordCount(profile.EnglishLevel),
            routeKey: englishTopic is not null ? TopicRoute(englishTopic.TopicId) : null,
            note: WeakTopicNote(englishTopic));

        // Madde 3: genel en zayıf konu için ek pekiştirme (kelime kartı).
        if (weakest is not null)
        {
            AddItem(plan, order: 3, activityType: "flashcard",
                title: $"{TrimTopic(weakest.TopicName)} Güçlendirme",
                targetCount: 5,
                routeKey: TopicRoute(weakest.TopicId),
                note: $"En çok zorlandığın konu bu. Kartlarla pekiştirerek kalıcı hale getirelim.");
        }

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

    private static void AddItem(DailyPlan plan, int order, string activityType, string title, int targetCount, string? routeKey = null, string? note = null)
    {
        plan.Items.Add(new DailyPlanItem
        {
            Id = Guid.NewGuid(),
            DailyPlanId = plan.Id,
            Order = order,
            ActivityType = activityType,
            Title = title,
            TargetCount = targetCount,
            RouteKey = routeKey,
            Note = note,
        });
    }

    // "Neden bu aktivite?" açıklaması: eşleşen zayıf konu varsa başarı oranıyla, yoksa null.
    private static string? WeakTopicNote(WeakTopicDto? topic)
    {
        if (topic is null) return null;
        var percent = (int)Math.Round(topic.SuccessRate * 100);
        return $"{TrimTopic(topic.TopicName)} konusundaki başarın %{percent}. Bugün burada pratik yaparak gelişebilirsin.";
    }

    private static int MathQuestionCount(GradeLevel grade) => grade == GradeLevel.PreSchool ? 3 : 5;

    private static int VocabWordCount(EnglishLevel? level) => level is null or EnglishLevel.A1 ? 5 : 6;

    // Mobil, RouteKey'i "topic:{id}" biçiminde okuyup ilgili konuya derin bağlantı kurabilir.
    private static string TopicRoute(Guid topicId) => $"topic:{topicId}";

    private static string TrimTopic(string name)
    {
        name = name.Trim();
        return name.Length <= MaxTopicNameLength ? name : name[..MaxTopicNameLength].TrimEnd();
    }

    private static bool IsMathSubject(string? subjectName)
        => subjectName?.Trim().StartsWith("Mat", StringComparison.OrdinalIgnoreCase) == true;

    private static bool IsEnglishSubject(string? subjectName)
    {
        if (string.IsNullOrWhiteSpace(subjectName)) return false;
        var normalized = subjectName.Trim().ToLowerInvariant();
        return normalized.Contains("ngiliz") || normalized.Contains("english");
    }
}
