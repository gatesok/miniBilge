using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class ClassroomMember
{
    public Guid          ClassroomId    { get; set; }
    public Guid          ChildProfileId { get; set; }
    public ClassroomRole Role           { get; set; } = ClassroomRole.Student;
    public DateTime      JoinedAt       { get; set; } = DateTime.UtcNow;

    // Navigation
    public virtual Classroom    Classroom    { get; set; } = null!;
    public virtual ChildProfile ChildProfile { get; set; } = null!;
}
