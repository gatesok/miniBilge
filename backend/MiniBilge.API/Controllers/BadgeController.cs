using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Badge;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Enums;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BadgeController : ControllerBase
{
    private readonly IBadgeRepository _badgeRepo;
    private readonly IGameStatsRepository _gameStatsRepo;
    private readonly IChildProfileRepository _childProfileRepo;

    public BadgeController(
        IBadgeRepository badgeRepo,
        IGameStatsRepository gameStatsRepo,
        IChildProfileRepository childProfileRepo)
    {
        _badgeRepo = badgeRepo;
        _gameStatsRepo = gameStatsRepo;
        _childProfileRepo = childProfileRepo;
    }

    /// <summary>
    /// Tüm rozet tanımlarını döndürür.
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        var badges = await _badgeRepo.GetAllAsync();
        var dtos = badges.Select(b => new BadgeDto
        {
            Id = b.Id,
            Key = b.Key,
            Name = b.Name,
            Description = b.Description,
            Emoji = b.Emoji,
            Category = b.Category,
            Rarity = b.Rarity,
            IsEarned = false,
        }).ToList();

        return Ok(dtos);
    }

    /// <summary>
    /// Çocuğun kazandığı rozetleri, tüm rozetlerle birleştirilmiş şekilde döndürür.
    /// </summary>
    [HttpGet("child/{childId}")]
    public async Task<IActionResult> GetChildCollection(Guid childId)
    {
        var allBadges = await _badgeRepo.GetAllAsync();
        var earned = await _badgeRepo.GetEarnedByChildAsync(childId);
        var earnedMap = earned.ToDictionary(cb => cb.BadgeId, cb => cb.EarnedAt);

        // Profil türü (child/adult) — rozet uygunluğu için.
        var profile = await _childProfileRepo.GetByIdAsync(childId);
        var profileType = profile?.GradeLevel == GradeLevel.Adult ? "adult" : "child";

        // İlerleme hesabı için güncel sayaç anlık görüntüleri (sayaçları değiştirmez).
        var challengeSnap = await _gameStatsRepo.GetSnapshotAsync(childId, "challenge");
        var liveSnap = await _gameStatsRepo.GetSnapshotAsync(childId, "live_match");
        var funGenelSnap = await _gameStatsRepo.GetSnapshotAsync(childId, "fun", "genel_kultur");
        var funKelimeSnap = await _gameStatsRepo.GetSnapshotAsync(childId, "fun", "kelime");
        var currentStreak = profile?.CurrentStreak ?? 0;

        var dtos = allBadges.Select(b =>
        {
            var isEarned = earnedMap.ContainsKey(b.Id);
            return new BadgeDto
            {
                Id = b.Id,
                Key = b.Key,
                Name = b.Name,
                Description = b.Description,
                Emoji = b.Emoji,
                Category = b.Category,
                Rarity = b.Rarity,
                IsEarned = isEarned,
                EarnedAt = earnedMap.TryGetValue(b.Id, out var dt) ? dt : null,
                IsApplicableToProfile = IsApplicable(b.ProfileScope, profileType),
                // İlerleme yalnızca henüz kazanılmamış rozetler için gösterilir.
                Progress = isEarned
                    ? null
                    : BadgeProgressCalculator.Compute(
                        b.Key, challengeSnap, liveSnap, funGenelSnap, funKelimeSnap, currentStreak),
            };
        }).ToList();

        return Ok(new BadgeCollectionDto
        {
            TotalBadges = allBadges.Count,
            EarnedCount = earned.Count,
            Badges = dtos,
        });
    }

    private static bool IsApplicable(string profileScope, string profileType)
        => string.IsNullOrEmpty(profileScope)
           || profileScope == "all"
           || profileScope == profileType;
}
