using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Badge;
using MiniBilge.Application.Interfaces.Repositories;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class BadgeController : ControllerBase
{
    private readonly IBadgeRepository _badgeRepo;

    public BadgeController(IBadgeRepository badgeRepo)
    {
        _badgeRepo = badgeRepo;
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

        var dtos = allBadges.Select(b => new BadgeDto
        {
            Id = b.Id,
            Key = b.Key,
            Name = b.Name,
            Description = b.Description,
            Emoji = b.Emoji,
            Category = b.Category,
            Rarity = b.Rarity,
            IsEarned = earnedMap.ContainsKey(b.Id),
            EarnedAt = earnedMap.TryGetValue(b.Id, out var dt) ? dt : null,
        }).ToList();

        return Ok(new BadgeCollectionDto
        {
            TotalBadges = allBadges.Count,
            EarnedCount = earned.Count,
            Badges = dtos,
        });
    }
}
