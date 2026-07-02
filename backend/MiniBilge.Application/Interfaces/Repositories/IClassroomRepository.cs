using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IClassroomRepository
{
    Task<Classroom>  CreateAsync(Guid ownerId, string name, string inviteCode);
    Task<Classroom?> GetByIdAsync(Guid id);
    Task<Classroom?> GetByInviteCodeAsync(string inviteCode);
    Task<List<Classroom>> GetByOwnerAsync(Guid ownerId);
    Task<List<Classroom>> GetByMemberAsync(Guid childProfileId);

    Task AddMemberAsync(Guid classroomId, Guid childProfileId);
    Task RemoveMemberAsync(Guid classroomId, Guid childProfileId);
    Task<bool> IsMemberAsync(Guid classroomId, Guid childProfileId);
    Task<List<ClassroomMember>> GetMembersAsync(Guid classroomId);

    Task<ClassroomAssignment> CreateAssignmentAsync(Guid classroomId, Guid levelId, string title, DateTime? dueDate, int minQuestions);
    Task<List<ClassroomAssignment>> GetAssignmentsAsync(Guid classroomId);
    Task<ClassroomAssignment?> GetAssignmentByIdAsync(Guid assignmentId);

    /// <summary>Öğrencinin verilen level'da aktif (tamamlanmamış) ödevi varsa döner.</summary>
    Task<ClassroomAssignment?> GetActiveAssignmentForChildAsync(Guid childProfileId, Guid levelId);

    Task<AssignmentProgress?> GetProgressAsync(Guid assignmentId, Guid childProfileId);
    Task UpsertProgressAsync(Guid assignmentId, Guid childProfileId, int completedQuestions, bool isCompleted);

    /// <summary>Sınıftaki her üye için tamamlanan ödev sayısını döner.</summary>
    Task<Dictionary<Guid, int>> GetMemberCompletedCountsAsync(Guid classroomId);

    /// <summary>Her ödev için tamamlayan üye sayısı ve ortalama doğru sayısını döner.</summary>
    Task<Dictionary<Guid, (int CompletedBy, int AverageCorrectCount)>> GetAssignmentCompletedStatsAsync(Guid classroomId);

    Task<bool> InviteCodeExistsAsync(string code);
}
