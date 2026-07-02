using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Classroom : BaseEntity
{
    public string Name       { get; set; } = string.Empty;
    public Guid   OwnerId    { get; set; }
    public string InviteCode { get; set; } = string.Empty;

    // Navigation
    public virtual User?                            Owner       { get; set; }
    public virtual ICollection<ClassroomMember>     Members     { get; set; } = new List<ClassroomMember>();
    public virtual ICollection<ClassroomAssignment> Assignments { get; set; } = new List<ClassroomAssignment>();
}
