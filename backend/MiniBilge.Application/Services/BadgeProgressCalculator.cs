using MiniBilge.Application.DTOs.Badge;
using MiniBilge.Application.Interfaces.Repositories;

namespace MiniBilge.Application.Services;

/// <summary>
/// Kilitli rozetler için sayısal ilerleme (3/5, %80 vb.) hesaplar.
/// Eşikler <see cref="Infrastructure"/> katmanındaki BadgeService koşullarıyla birebir aynı olmalıdır.
/// İlerlemesi hesaplanamayan (ör. tek seferlik/özel) rozetler için null döner.
/// </summary>
public static class BadgeProgressCalculator
{
    /// <param name="challenge">Meydan okuma (challenge) toplam anlık görüntüsü.</param>
    /// <param name="live">Canlı yarış (live_match) toplam anlık görüntüsü.</param>
    /// <param name="funGenelKultur">Eğlence toplamı + "genel_kultur" kategori anlık görüntüsü.</param>
    /// <param name="funKelime">Eğlence toplamı + "kelime" kategori anlık görüntüsü.</param>
    /// <param name="currentStreak">Güncel günlük öğrenme serisi.</param>
    public static BadgeProgressDto? Compute(
        string badgeKey,
        GameStatSnapshot challenge,
        GameStatSnapshot live,
        GameStatSnapshot funGenelKultur,
        GameStatSnapshot funKelime,
        int currentStreak)
    {
        return badgeKey switch
        {
            // ── Günlük seri ──────────────────────────────────────────────
            "streak_3" => Bar(currentStreak, 3, "days"),
            "streak_7" => Bar(currentStreak, 7, "days"),
            "streak_30" => Bar(currentStreak, 30, "days"),

            // ── Meydan okuma ─────────────────────────────────────────────
            "challenge_first_win" => Bar(challenge.TotalWon, 1),
            "challenge_wins_10" => Bar(challenge.TotalWon, 10),
            "challenge_wins_50" => Bar(challenge.TotalWon, 50),
            "challenge_streak_5" => Bar(challenge.BestWinStreak, 5, "streak"),
            "challenge_perfect_win" => Bar(challenge.TotalPerfectWins, 1),
            "challenge_variety" => Bar(challenge.DistinctCategoriesWon, 3, "categories"),

            // ── Canlı yarış ──────────────────────────────────────────────
            "live_matches_10" => Bar(live.TotalPlayed, 10),
            "live_wins_10" => Bar(live.TotalWon, 10),
            "live_perfect_win" => Bar(live.TotalPerfectWins, 1),
            // live_comeback pasiftir; ilerleme gösterilmez.
            "live_variety" => Bar(live.DistinctCategoriesWon, 3, "categories"),

            // ── Eğlence quizi ────────────────────────────────────────────
            "fun_first_quiz" => Bar(funGenelKultur.TotalPlayed, 1),
            "fun_quizzes_10" => Bar(funGenelKultur.TotalPlayed, 10),
            "fun_quizzes_50" => Bar(funGenelKultur.TotalPlayed, 50),
            "fun_perfect" => Bar(funGenelKultur.TotalPerfectWins, 1),
            "fun_categories_5" => Bar(funGenelKultur.DistinctCategoriesWon, 5, "categories"),
            "general_culture_master" => Bar(funGenelKultur.CategoryPlayed, 10),
            "word_game_master" => Bar(funKelime.CategoryPlayed, 10),

            _ => null,
        };
    }

    private static BadgeProgressDto Bar(int current, int target, string unit = "count")
        => new()
        {
            Current = Math.Clamp(current, 0, target),
            Target = target,
            Unit = unit,
        };
}
