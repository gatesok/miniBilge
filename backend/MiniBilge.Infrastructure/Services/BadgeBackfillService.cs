using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// Sprint 2 rozet ailelerini mevcut profillere geriye dönük veren backfill servisi.
/// Ayrıntılar için <see cref="IBadgeBackfillService"/>.
/// </summary>
public class BadgeBackfillService : IBadgeBackfillService
{
    private readonly IChildProfileRepository _childProfileRepo;
    private readonly IGameStatsRepository _gameStatsRepo;
    private readonly IBadgeRepository _badgeRepo;
    private readonly ILogger<BadgeBackfillService> _logger;

    public BadgeBackfillService(
        IChildProfileRepository childProfileRepo,
        IGameStatsRepository gameStatsRepo,
        IBadgeRepository badgeRepo,
        ILogger<BadgeBackfillService> logger)
    {
        _childProfileRepo = childProfileRepo;
        _gameStatsRepo = gameStatsRepo;
        _badgeRepo = badgeRepo;
        _logger = logger;
    }

    public async Task<BadgeBackfillReport> RunAsync(bool apply, CancellationToken cancellationToken = default)
    {
        var profiles = await _childProfileRepo.GetAllAsync(cancellationToken);
        var counts = new Dictionary<string, int>();

        foreach (var profile in profiles)
        {
            cancellationToken.ThrowIfCancellationRequested();

            var challenge = await _gameStatsRepo.GetSnapshotAsync(profile.Id, "challenge");
            var live = await _gameStatsRepo.GetSnapshotAsync(profile.Id, "live_match");
            var fun = await _gameStatsRepo.GetSnapshotAsync(profile.Id, "fun");
            var funGenelKultur = await _gameStatsRepo.GetSnapshotAsync(profile.Id, "fun", "genel_kultur");
            var funKelime = await _gameStatsRepo.GetSnapshotAsync(profile.Id, "fun", "kelime");

            foreach (var key in GetBackfillableKeys(challenge, live, fun, funGenelKultur, funKelime))
            {
                var badge = await _badgeRepo.GetByKeyAsync(key);
                if (badge == null) continue; // Katalogda yoksa (SQL çalıştırılmamışsa) atla.

                if (await _badgeRepo.HasEarnedAsync(profile.Id, key)) continue; // Idempotent: mükerrer verme.

                counts[key] = counts.GetValueOrDefault(key) + 1;

                if (apply)
                    await _badgeRepo.AwardAsync(profile.Id, badge.Id);
            }
        }

        var report = new BadgeBackfillReport
        {
            Applied = apply,
            ProfilesScanned = profiles.Count,
            TotalAwarded = counts.Values.Sum(),
            Badges = counts
                .Select(kv => new BadgeBackfillItem { BadgeKey = kv.Key, EligibleProfiles = kv.Value })
                .OrderByDescending(i => i.EligibleProfiles)
                .ThenBy(i => i.BadgeKey)
                .ToList(),
        };

        _logger.LogInformation(
            "[BADGE-BACKFILL] apply={Apply} profiller={Profiles} toplamRozet={Total}",
            apply, report.ProfilesScanned, report.TotalAwarded);

        return report;
    }

    /// <summary>
    /// Güncel sayaçlardan güvenle türetilebilen backfill rozetleri. Seri
    /// (challenge_streak_5), kusursuz galibiyet (challenge_perfect_win,
    /// live_perfect_win, fun_perfect) ve geri dönüş (live_comeback) rozetleri
    /// olay sırası gerektirdiği için kapsam dışıdır.
    /// Eşikler <c>BadgeService.GetCandidateKeys</c> ile birebir aynıdır.
    /// </summary>
    private static IEnumerable<string> GetBackfillableKeys(
        GameStatSnapshot challenge,
        GameStatSnapshot live,
        GameStatSnapshot fun,
        GameStatSnapshot funGenelKultur,
        GameStatSnapshot funKelime)
    {
        // ── Meydan okuma (toplam galibiyet / çeşitlilik)
        if (challenge.TotalWon >= 1) yield return "challenge_first_win";
        if (challenge.TotalWon >= 10) yield return "challenge_wins_10";
        if (challenge.TotalWon >= 50) yield return "challenge_wins_50";
        if (challenge.DistinctCategoriesWon >= 3) yield return "challenge_variety";

        // ── Canlı yarış (oynanan / toplam galibiyet / çeşitlilik)
        if (live.TotalPlayed >= 10) yield return "live_matches_10";
        if (live.TotalWon >= 10) yield return "live_wins_10";
        if (live.DistinctCategoriesWon >= 3) yield return "live_variety";

        // ── Eğlence quizi (toplam / çeşitlilik / ustalık)
        if (fun.TotalPlayed >= 1) yield return "fun_first_quiz";
        if (fun.TotalPlayed >= 10) yield return "fun_quizzes_10";
        if (fun.TotalPlayed >= 50) yield return "fun_quizzes_50";
        if (fun.DistinctCategoriesWon >= 5) yield return "fun_categories_5";
        if (funGenelKultur.CategoryPlayed >= 10 && funGenelKultur.CategoryAverageSuccessPercentage >= 80)
            yield return "general_culture_master";
        if (funKelime.CategoryPlayed >= 10) yield return "word_game_master";
    }
}
