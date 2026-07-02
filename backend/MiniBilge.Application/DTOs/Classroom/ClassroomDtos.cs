namespace MiniBilge.Application.DTOs.Classroom;

// ── Input DTO'ları ────────────────────────────────────────────────────────────

public record CreateClassroomDto(string Name);

public record JoinClassroomDto(string InviteCode);

public record CreateAssignmentDto(
    Guid      LevelId,
    string    Title,
    DateTime? DueDate,
    int       MinQuestions = 10);

public record UpdateProgressDto(int CompletedQuestions);

// ── Output DTO'ları ───────────────────────────────────────────────────────────

public class ClassroomDto
{
    public Guid                      Id          { get; set; }
    public string                    Name        { get; set; } = string.Empty;
    public string                    InviteCode  { get; set; } = string.Empty;
    public int                       MemberCount { get; set; }
    public string                    MyRole      { get; set; } = string.Empty; // "Owner" | "Student"
    public List<AssignmentSummaryDto> Assignments { get; set; } = new();
}

public class ClassroomDetailDto : ClassroomDto
{
    public List<ClassroomMemberDto>     Members { get; set; } = new();
}

public class ClassroomMemberDto
{
    public Guid   ChildProfileId       { get; set; }
    public string Name                 { get; set; } = string.Empty;
    public string? AvatarUrl           { get; set; }
    public int    CompletedAssignments { get; set; }
}

public class AssignmentSummaryDto
{
    public Guid     Id           { get; set; }
    public string   Title        { get; set; } = string.Empty;
    public string   TopicName    { get; set; } = string.Empty;
    public string   SubjectName  { get; set; } = string.Empty;
    public DateTime? DueDate     { get; set; }
    public int      MinQuestions { get; set; }
    public int      MyProgress   { get; set; }   // tamamlanan soru sayısı
    public bool     IsCompleted  { get; set; }
    public int      MemberCount  { get; set; }   // sınıf üye sayısı (owner için)
    public int      CompletedBy  { get; set; }   // kaç kişi tamamladı (owner için)
}
