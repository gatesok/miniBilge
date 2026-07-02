using MiniBilge.Application.DTOs.Classroom;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Application.Interfaces.Services;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Services;

public class ClassroomService : IClassroomService
{
    private readonly IClassroomRepository    _repo;
    private readonly IChildProfileRepository _childRepo;

    public ClassroomService(IClassroomRepository repo, IChildProfileRepository childRepo)
    {
        _repo      = repo;
        _childRepo = childRepo;
    }

    // ── Oluştur ───────────────────────────────────────────────────────────────

    public async Task<ClassroomDto> CreateClassroomAsync(Guid ownerId, string name)
    {
        var code = await GenerateUniqueCodeAsync();
        var classroom = await _repo.CreateAsync(ownerId, name, code);
        return MapToDto(classroom, viewerUserId: ownerId, viewerChildId: null);
    }

    // ── Katıl ─────────────────────────────────────────────────────────────────

    public async Task<ClassroomDto> JoinByCodeAsync(string inviteCode, Guid childProfileId)
    {
        var classroom = await _repo.GetByInviteCodeAsync(inviteCode.ToUpperInvariant())
            ?? throw new KeyNotFoundException("Geçersiz davet kodu.");

        if (await _repo.IsMemberAsync(classroom.Id, childProfileId))
            throw new InvalidOperationException("Bu sınıfa zaten üyesiniz.");

        await _repo.AddMemberAsync(classroom.Id, childProfileId);

        var full = await _repo.GetByIdAsync(classroom.Id);
        return MapToDto(full!, viewerUserId: null, viewerChildId: childProfileId);
    }

    // ── Ayrıl ─────────────────────────────────────────────────────────────────

    public async Task LeaveAsync(Guid classroomId, Guid childProfileId)
    {
        if (!await _repo.IsMemberAsync(classroomId, childProfileId))
            throw new InvalidOperationException("Bu sınıfın üyesi değilsiniz.");

        await _repo.RemoveMemberAsync(classroomId, childProfileId);
    }

    // ── Listele ───────────────────────────────────────────────────────────────

    public async Task<List<ClassroomDto>> GetMyClassroomsAsync(Guid childProfileId, Guid userId)
    {
        var owned  = await _repo.GetByOwnerAsync(userId);
        var joined = await _repo.GetByMemberAsync(childProfileId);

        // Sahip olunanlar + üye olunanlar (duplicate'siz)
        var all = owned
            .Concat(joined.Where(j => owned.All(o => o.Id != j.Id)))
            .ToList();

        return all.Select(c => MapToDto(c, viewerUserId: userId, viewerChildId: childProfileId)).ToList();
    }

    // ── Detay ─────────────────────────────────────────────────────────────────

    public async Task<ClassroomDetailDto> GetDetailAsync(Guid classroomId, Guid viewerChildId, Guid viewerUserId = default)
    {
        var classroom = await _repo.GetByIdAsync(classroomId)
            ?? throw new KeyNotFoundException("Sınıf bulunamadı.");

        // Doğrudan DB sorgusu — include chain'e güvenmez
        var completedCounts = await _repo.GetMemberCompletedCountsAsync(classroomId);

        var members = classroom.Members.ToList();
        var memberDtos = members.Select(m =>
        {
            completedCounts.TryGetValue(m.ChildProfileId, out var completed);
            return new ClassroomMemberDto
            {
                ChildProfileId       = m.ChildProfileId,
                Name                 = m.ChildProfile.Name,
                AvatarUrl            = null,
                CompletedAssignments = completed,
            };
        }).ToList();

        var dto = new ClassroomDetailDto
        {
            Id          = classroom.Id,
            Name        = classroom.Name,
            InviteCode  = classroom.InviteCode,
            MemberCount = members.Count,
            MyRole      = classroom.OwnerId == viewerUserId ? "Owner" : "Student",
            Assignments = MapAssignments(classroom.Assignments.ToList(), viewerChildId, members.Count),
            Members     = memberDtos,
        };
        return dto;
    }

    // ── Ödev Oluştur ─────────────────────────────────────────────────────────

    public async Task<AssignmentSummaryDto> CreateAssignmentAsync(
        Guid classroomId, Guid ownerUserId, CreateAssignmentDto dto)
    {
        var classroom = await _repo.GetByIdAsync(classroomId)
            ?? throw new KeyNotFoundException("Sınıf bulunamadı.");

        if (classroom.OwnerId != ownerUserId)
            throw new UnauthorizedAccessException("Yalnızca sınıf sahibi ödev atayabilir.");

        var assignment = await _repo.CreateAssignmentAsync(
            classroomId, dto.LevelId, dto.Title, dto.DueDate, dto.MinQuestions);

        var full = await _repo.GetAssignmentByIdAsync(assignment.Id);
        return MapAssignment(full!, viewerChildId: Guid.Empty, memberCount: classroom.Members.Count);
    }

    // ── Quiz Hook ─────────────────────────────────────────────────────────────

    public async Task UpdateProgressIfAssignedAsync(Guid childProfileId, Guid levelId, int completedQuestions)
    {
        var assignment = await _repo.GetActiveAssignmentForChildAsync(childProfileId, levelId);
        if (assignment == null) return;

        var isCompleted = true; // Quiz tamamlandığında ödev her zaman done sayılır
        await _repo.UpsertProgressAsync(assignment.Id, childProfileId, completedQuestions, isCompleted);
    }

    // ── Mapping ───────────────────────────────────────────────────────────────

    private static ClassroomDto MapToDto(Classroom c, Guid? viewerUserId, Guid? viewerChildId)
    {
        var isOwner = viewerUserId.HasValue && c.OwnerId == viewerUserId;
        var memberCount = c.Members?.Count ?? 0;
        return new ClassroomDto
        {
            Id          = c.Id,
            Name        = c.Name,
            InviteCode  = c.InviteCode,
            MemberCount = memberCount,
            MyRole      = isOwner ? "Owner" : "Student",
            Assignments = MapAssignments(c.Assignments?.ToList() ?? new(), viewerChildId ?? Guid.Empty, memberCount),
        };
    }

    private static List<AssignmentSummaryDto> MapAssignments(
        List<ClassroomAssignment> assignments, Guid viewerChildId, int memberCount)
        => assignments
            .Where(a => !a.IsDeleted)
            .Select(a => MapAssignment(a, viewerChildId, memberCount))
            .ToList();

    private static AssignmentSummaryDto MapAssignment(
        ClassroomAssignment a, Guid viewerChildId, int memberCount)
    {
        var myProgress = a.Progress.FirstOrDefault(p => p.ChildProfileId == viewerChildId);
        return new AssignmentSummaryDto
        {
            Id          = a.Id,
            LevelId     = a.LevelId,
            Title       = a.Title,
            TopicName   = a.Level?.Topic?.Name ?? string.Empty,
            SubjectName = a.Level?.Topic?.Subject?.Name ?? string.Empty,
            DueDate     = a.DueDate,
            MinQuestions = a.MinQuestions,
            MyProgress  = myProgress?.CompletedQuestions ?? 0,
            IsCompleted = myProgress?.CompletedAt != null,
            MemberCount = memberCount,
            CompletedBy = a.Progress.Count(p => p.CompletedAt != null),
            AverageCorrectCount = a.Progress.Any(p => p.CompletedAt != null)
                ? (int)Math.Round(a.Progress.Where(p => p.CompletedAt != null)
                    .Average(p => p.CompletedQuestions))
                : 0,
        };
    }

    // ── Helpers ───────────────────────────────────────────────────────────────

    private async Task<string> GenerateUniqueCodeAsync()
    {
        const string chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // okunması kolay karakterler
        var rng = new Random();
        string code;
        do
        {
            code = new string(Enumerable.Range(0, 6).Select(_ => chars[rng.Next(chars.Length)]).ToArray());
        }
        while (await _repo.InviteCodeExistsAsync(code));
        return code;
    }
}
