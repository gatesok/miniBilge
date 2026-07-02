using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class ClassroomAssignment : BaseEntity
{
    public Guid      ClassroomId  { get; set; }
    public Guid      LevelId      { get; set; }
    public string    Title        { get; set; } = string.Empty;
    public DateTime? DueDate      { get; set; }
    public int       MinQuestions { get; set; } = 10;

    // Navigation
    public virtual Classroom                        Classroom  { get; set; } = null!;
    public virtual Level                            Level      { get; set; } = null!;
    public virtual ICollection<AssignmentProgress>  Progress   { get; set; } = new List<AssignmentProgress>();
}
