using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using MiniBilge.Application.DTOs.Avatar;
using MiniBilge.Application.Interfaces;

namespace MiniBilge.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize(Roles = "Parent")]
public class AvatarController : ControllerBase
{
    private readonly IAvatarService _avatarService;

    public AvatarController(IAvatarService avatarService)
    {
        _avatarService = avatarService;
    }

    /// <summary>
    /// Tüm aktif avatar aksesuarlarını listeler
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID (owned/equipped kontrolü için)</param>
    [HttpGet("items")]
    public async Task<ActionResult<List<AvatarItemDto>>> GetItems([FromQuery] Guid childProfileId)
    {
        try
        {
            var items = await _avatarService.GetAvailableItemsAsync(childProfileId);
            return Ok(items);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Items yüklenirken hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun sahip olduğu aksesuarları listeler
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    [HttpGet("child/{childProfileId}/owned")]
    public async Task<ActionResult<List<AvatarItemDto>>> GetOwnedItems(Guid childProfileId)
    {
        try
        {
            var items = await _avatarService.GetOwnedItemsAsync(childProfileId);
            return Ok(items);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Envanter yüklenirken hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun equipped aksesuarlarını listeler
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    [HttpGet("child/{childProfileId}/equipped")]
    public async Task<ActionResult<List<EquippedItemDto>>> GetEquippedItems(Guid childProfileId)
    {
        try
        {
            var items = await _avatarService.GetEquippedItemsAsync(childProfileId);
            return Ok(items);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Equipped items yüklenirken hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Çocuğun tüm avatar bilgilerini getirir (equipped items dahil)
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    [HttpGet("child/{childProfileId}")]
    public async Task<ActionResult<ChildAvatarDto>> GetChildAvatar(Guid childProfileId)
    {
        try
        {
            var avatar = await _avatarService.GetChildAvatarAsync(childProfileId);
            return Ok(avatar);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Avatar bilgileri yüklenirken hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Aksesuar satın alma
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    /// <param name="itemId">Aksesuar ID</param>
    [HttpPost("child/{childProfileId}/purchase/{itemId}")]
    public async Task<ActionResult<PurchaseItemResponse>> PurchaseItem(Guid childProfileId, Guid itemId)
    {
        try
        {
            var response = await _avatarService.PurchaseItemAsync(childProfileId, itemId);
            
            if (!response.Success)
                return BadRequest(response);

            return Created($"/api/avatar/child/{childProfileId}/owned", response);
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Satın alma işlemi sırasında hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Aksesuarı equip et (avatara uygula)
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    /// <param name="itemId">Aksesuar ID</param>
    [HttpPost("child/{childProfileId}/equip/{itemId}")]
    public async Task<ActionResult> EquipItem(Guid childProfileId, Guid itemId)
    {
        try
        {
            var success = await _avatarService.EquipItemAsync(childProfileId, itemId);
            
            if (!success)
                return BadRequest(new { message = "Aksesuar equip edilemedi. Sahip olduğunuzdan emin olun." });

            return Ok(new { message = "Aksesuar başarıyla kullanıldı!" });
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Equip işlemi sırasında hata oluştu", error = ex.Message });
        }
    }

    /// <summary>
    /// Aksesuarı unequip et (avatardan kaldır)
    /// </summary>
    /// <param name="childProfileId">Çocuk profil ID</param>
    /// <param name="itemId">Aksesuar ID</param>
    [HttpDelete("child/{childProfileId}/unequip/{itemId}")]
    public async Task<ActionResult> UnequipItem(Guid childProfileId, Guid itemId)
    {
        try
        {
            await _avatarService.UnequipItemAsync(childProfileId, itemId);
            return NoContent();
        }
        catch (Exception ex)
        {
            return StatusCode(500, new { message = "Unequip işlemi sırasında hata oluştu", error = ex.Message });
        }
    }
}
