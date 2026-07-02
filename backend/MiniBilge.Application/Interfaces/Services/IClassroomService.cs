using MiniBilge.Application.DTOs.Classroom;

namespace MiniBilge.Application.Interfaces.Services;

public interface IClassroomService
{
    Task<ClassroomDto>    CreateClassroomAsync(Guid ownerId, string name);
    Task<ClassroomDto>    JoinByCodeAsync(string inviteCode, Guid childProfileId);
    Task                  LeaveAsync(Guid classroomId, Guid childProfileId);
    Task<List<ClassroomDto>> GetMyClassroomsAsync(Guid childProfileId, Guid userId);
    Task<ClassroomDetailDto> GetDetailAsync(Guid classroomId, Guid viewerChildId);

    Task<AssignmentSummaryDto> CreateAssignmentAsync(Guid classroomId, Guid ownerUserId, CreateAssignmentDto dto);

    /// <summary>Quiz tamamlandığında çağrılır. Aktif ödev varsa ilerlemeyi günceller.</summary>
    Task UpdateProgressIfAssignedAsync(Guid childProfileId, Guid levelId, int completedQuestions);
}
