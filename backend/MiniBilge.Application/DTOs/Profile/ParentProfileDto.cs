namespace MiniBilge.Application.DTOs.Profile;

public class ParentProfileDto
{
    public Guid Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    public int ChildrenCount { get; set; }
}
