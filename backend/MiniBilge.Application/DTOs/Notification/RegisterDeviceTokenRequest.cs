using System.ComponentModel.DataAnnotations;

namespace MiniBilge.Application.DTOs.Notification;

public class RegisterDeviceTokenRequest
{
    [Required]
    public Guid ChildProfileId { get; set; }

    [Required]
    [MaxLength(500)]
    public string Token { get; set; } = string.Empty;

    [MaxLength(10)]
    public string Platform { get; set; } = "ios";
}
