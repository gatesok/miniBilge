using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

public class BadgeService : IBadgeService
{
    private readonly IBadgeRepository _badgeRepo;
    private readonly ILogger<BadgeService> _logger;

    public BadgeService(IBadgeRepository badgeRepo, ILogger<BadgeService> logger)
    {
        _badgeRepo = badgeRepo;
        _logger = logger;
    }

    public async Task<IReadOnlyList<string>> CheckAndAwardAsync(
        Guid childProfileId,
        BadgeTrigger trigger,
        BadgeTriggerContext? ctx = null)
    {
        var awarded = new List<string>();

        try
        {
            var candidates = GetCandidateKeys(trigger, ctx);
            foreach (var key in candidates)
            {
                var badge = await _badgeRepo.GetByKeyAsync(key);
                if (badge == null) continue;

                var alreadyHas = await _badgeRepo.HasEarnedAsync(childProfileId, key);
                if (alreadyHas) continue;

                await _badgeRepo.AwardAsync(childProfileId, badge.Id);
                awarded.Add(key);
                _logger.LogInformation("[BADGE] Child {ChildId} earned badge '{Key}'", childProfileId, key);
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "[BADGE] Error while checking badges for child {ChildId}", childProfileId);
        }

        return awarded;
    }

    /// <summary>
    /// Trigger + context'e göre kontrol edilecek rozet key'lerini döndürür.
    /// </summary>
    private static IEnumerable<string> GetCandidateKeys(BadgeTrigger trigger, BadgeTriggerContext? ctx)
    {
        switch (trigger)
        {
            case BadgeTrigger.QuizCompleted:
                yield return "first_quiz";

                if (ctx?.SuccessPercentage >= 100)
                    yield return "perfectionist";

                if (ctx?.TopicsCompletedToday >= 3)
                    yield return "busy_bee";

                if (ctx?.TotalTopicsCompleted >= 10 && ctx.SubjectName == "Matematik")
                    yield return "math_master";

                if (ctx?.SubjectName == "İngilizce" && ctx.EnglishLevel == "A1")
                    yield return "english_a1";

                if (ctx?.SubjectName == "İngilizce" && ctx.EnglishLevel == "B1")
                    yield return "english_b1";

                if (ctx?.QuestionAnswerSeconds <= 5)
                    yield return "lightning";

                if (ctx?.QuizDurationSeconds <= 120)
                    yield return "speed_train";

                if (ctx?.TotalTopicsCompleted >= 1)
                    yield return "topic_master";

                break;

            case BadgeTrigger.StreakUpdated:
                if (ctx?.CurrentStreak >= 3)
                    yield return "streak_3";
                if (ctx?.CurrentStreak >= 7)
                    yield return "streak_7";
                if (ctx?.CurrentStreak >= 30)
                    yield return "streak_30";
                break;

            case BadgeTrigger.MatchCompleted:
                if (ctx?.MatchWon == true)
                {
                    yield return "first_win";

                    if (ctx.ConsecutiveMatchWins >= 5)
                        yield return "win_streak_5";

                    if (ctx.TotalMatchWins >= 50)
                        yield return "champion_50";
                }
                break;

            case BadgeTrigger.ProfileCreated:
                yield return "beta_hero";
                // early_bird: ilk 100 kullanıcı — bu kontrol BadgeController'da ayrıca yapılır
                break;
        }
    }
}
