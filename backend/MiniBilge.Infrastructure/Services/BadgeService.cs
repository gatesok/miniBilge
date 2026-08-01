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

        List<string> candidates;
        try
        {
            candidates = GetCandidateKeys(trigger, ctx).ToList();
        }
        catch (Exception ex)
        {
            // Aday listesi hesaplanamazsa logla + metrik üret; ana akışı engelleme.
            BadgeMetrics.EvaluationErrors.Add(1, new KeyValuePair<string, object?>("stage", "candidates"));
            _logger.LogError(ex, "[BADGE] Aday rozet listesi hesaplanırken hata (child {ChildId}, trigger {Trigger})",
                childProfileId, trigger);
            return awarded;
        }

        foreach (var key in candidates)
        {
            try
            {
                var badge = await _badgeRepo.GetByKeyAsync(key);
                if (badge == null) continue;

                var alreadyHas = await _badgeRepo.HasEarnedAsync(childProfileId, key);
                if (alreadyHas) continue;

                await _badgeRepo.AwardAsync(childProfileId, badge.Id);
                awarded.Add(key);
                BadgeMetrics.Awarded.Add(1, new KeyValuePair<string, object?>("badge", key));
                _logger.LogInformation("[BADGE] Child {ChildId} earned badge '{Key}'", childProfileId, key);
            }
            catch (Exception ex)
            {
                // Bir rozetin hatası diğer rozetleri ve ana oyun sonucunu engellemez.
                BadgeMetrics.EvaluationErrors.Add(1, new KeyValuePair<string, object?>("badge", key));
                _logger.LogError(ex, "[BADGE] '{Key}' rozeti değerlendirilirken hata (child {ChildId})",
                    key, childProfileId);
            }
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
                if (ctx?.IsEligibleNewQuiz == true)
                    yield return "first_quiz";

                if (ctx?.SuccessPercentage >= 100)
                    yield return "perfectionist";

                if (ctx?.TopicsCompletedToday >= 3)
                    yield return "busy_bee";

                // Sayıların Efendisi: yalnızca tamamen bitirilmiş matematik konuları sayılır
                if (ctx?.MathTopicsCompleted >= 10)
                    yield return "math_master";

                // Kelime Avcısı: tüm A1 içeriği tamamlandığında
                if (ctx?.EnglishA1Completed == true)
                    yield return "english_a1";

                // CEFR Yolcusu: B1 seviyesine gerçekten ulaşıldığında
                if (ctx?.EnglishReachedB1 == true)
                    yield return "english_b1";

                if (ctx?.QuestionAnswerSeconds <= 5)
                    yield return "lightning";

                if (ctx?.QuizDurationSeconds <= 120)
                    yield return "speed_train";

                // Konu Ustası: bir konunun gerekli tüm seviyeleri tamamlandığında
                if (ctx?.TopicJustCompleted == true)
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

                    // Kusursuz Zafer: canlı yarışı tam puanla kazan
                    if (ctx.LivePerfectWin)
                        yield return "live_perfect_win";

                    // Geri Dönüş Ustası: geriden gelerek kazan
                    if (ctx.LiveComebackWin)
                        yield return "live_comeback";

                    // Canlı Yarışçı: 10 canlı yarış kazan
                    if (ctx.TotalMatchWins >= 10)
                        yield return "live_wins_10";

                    // Arena Bilgesi: 3 farklı kategoride kazan
                    if (ctx.DistinctLiveCategoriesWon >= 3)
                        yield return "live_variety";
                }

                // Arenaya Alışıyorum: 10 canlı yarış tamamla (kazanmak şart değil)
                if (ctx?.TotalLiveMatchesPlayed >= 10)
                    yield return "live_matches_10";
                break;

            case BadgeTrigger.ChallengeCompleted:
                if (ctx?.ChallengeWon == true)
                {
                    // İlk Meydan Okuma
                    yield return "challenge_first_win";

                    if (ctx.TotalChallengeWins >= 10)
                        yield return "challenge_wins_10";

                    if (ctx.TotalChallengeWins >= 50)
                        yield return "challenge_wins_50";

                    if (ctx.ConsecutiveChallengeWins >= 5)
                        yield return "challenge_streak_5";

                    // Kusursuz Düello: tüm soruları doğru cevaplayarak kazan
                    if (ctx.ChallengePerfectWin)
                        yield return "challenge_perfect_win";

                    // Çok Yönlü Rakip: 3 farklı kategoride kazan
                    if (ctx.DistinctChallengeCategoriesWon >= 3)
                        yield return "challenge_variety";
                }
                break;

            case BadgeTrigger.FunQuizCompleted:
                // Eğlence Başlasın: ilk eğlence quizi
                if (ctx?.TotalFunQuizzesCompleted >= 1)
                    yield return "fun_first_quiz";

                if (ctx?.TotalFunQuizzesCompleted >= 10)
                    yield return "fun_quizzes_10";

                if (ctx?.TotalFunQuizzesCompleted >= 50)
                    yield return "fun_quizzes_50";

                // Eğlencede Kusursuz: bir eğlence quizini %100 tamamla
                if (ctx?.FunPerfect == true)
                    yield return "fun_perfect";

                // Kategori Kaşifi: 5 farklı eğlence kategorisi
                if (ctx?.DistinctFunCategoriesCompleted >= 5)
                    yield return "fun_categories_5";

                // Genel Kültür Ustası: genel kültürde 10 quiz ve ≥%80 ortalama
                if (ctx?.FunCategoryKey == "genel_kultur"
                    && ctx.FunCategoryCompletedCount >= 10
                    && ctx.FunCategoryAverageSuccess >= 80)
                    yield return "general_culture_master";

                // Kelime Ustası: 10 kelime oyunu tamamla
                if (ctx?.FunCategoryKey == "kelime"
                    && ctx.FunCategoryCompletedCount >= 10)
                    yield return "word_game_master";
                break;

            case BadgeTrigger.ProfileCreated:
                // Beta Kahramanı: v1.0 döneminde oluşturulan her profile verilir.
                yield return "beta_hero";
                // Erken Kuş: sistemdeki ilk 100 profilden biriyse.
                if (ctx?.IsAmongFirst100 == true)
                    yield return "early_bird";
                break;
        }
    }
}
