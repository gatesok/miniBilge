namespace MiniBilge.Application.DTOs.Avatar;

public class AvatarDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string ImageUrl { get; set; } = string.Empty;
    public bool IsDefault { get; set; }
}
