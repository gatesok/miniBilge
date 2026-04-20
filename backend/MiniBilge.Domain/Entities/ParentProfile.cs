using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class ParentProfile : BaseEntity
{
    public Guid UserId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string LastName { get; set; } = string.Empty;
    public string? PhoneNumber { get; set; }
    
    // Navigation
    public User User { get; set; } = null!;
    public ICollection<ChildProfile> Children { get; set; } = new List<ChildProfile>();
}
