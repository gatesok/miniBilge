namespace MiniBilge.Domain.Entities;

public class AssignmentProgress
{
    public Guid      AssignmentId       { get; set; }
    public Guid      ChildProfileId     { get; set; }
    public int       CompletedQuestions { get; set; } = 0;
    public DateTime? CompletedAt        { get; set; }
    public DateTime  UpdatedAt          { get; set; } = DateTime.UtcNow;

    // Navigation
    public virtual ClassroomAssignment Assignment   { get; set; } = null!;
    public virtual ChildProfile        ChildProfile { get; set; } = null!;
}
