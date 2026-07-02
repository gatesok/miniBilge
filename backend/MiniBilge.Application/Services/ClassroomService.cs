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

    public async Task<ClassroomDto> CreateClassroomAsync(Guid ownerId, Guid childId, string name)
    {
        var child = await _childRepo.GetByIdAsync(childId)
            ?? throw new KeyNotFoundException("Çocuk profili bulunamadı.");
        if (!child.IsTeacher)
            throw new UnauthorizedAccessException("Yalnızca öğretmen profilleri sınıf oluşturabilir.");

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

        // Doğrudan DB sorguları — include chain'e güvenmez
        var completedCounts  = await _repo.GetMemberCompletedCountsAsync(classroomId);
        var assignmentStats  = await _repo.GetAssignmentCompletedStatsAsync(classroomId);

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
            Assignments = MapAssignments(classroom.Assignments.ToList(), viewerChildId, members.Count, assignmentStats),
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
        List<ClassroomAssignment> assignments, Guid viewerChildId, int memberCount,
        Dictionary<Guid, (int CompletedBy, int AverageCorrectCount)>? stats = null)
        => assignments
            .Where(a => !a.IsDeleted)
            .Select(a => MapAssignment(a, viewerChildId, memberCount, stats))
            .ToList();

    private static AssignmentSummaryDto MapAssignment(
        ClassroomAssignment a, Guid viewerChildId, int memberCount,
        Dictionary<Guid, (int CompletedBy, int AverageCorrectCount)>? stats = null)
    {
        var myProgress = a.Progress.FirstOrDefault(p => p.ChildProfileId == viewerChildId);

        // Direkt DB sorgusu varsa onu kullan, yoksa include chain'e dön
        int completedBy, avgCorrect;
        if (stats != null && stats.TryGetValue(a.Id, out var s))
        {
            completedBy = s.CompletedBy;
            avgCorrect  = s.AverageCorrectCount;
        }
        else
        {
            completedBy = a.Progress.Count(p => p.CompletedAt != null);
            avgCorrect  = a.Progress.Any(p => p.CompletedAt != null)
                ? (int)Math.Round(a.Progress.Where(p => p.CompletedAt != null)
                    .Average(p => p.CompletedQuestions))
                : 0;
        }

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
            CompletedBy = completedBy,
            AverageCorrectCount = avgCorrect,
        };
    }

    // ── Ödev Detayı (Teacher) ─────────────────────────────────────────────────

    public async Task<AssignmentDetailDto> GetAssignmentDetailAsync(Guid classroomId, Guid assignmentId, Guid viewerUserId)
    {
        var data = await _repo.GetAssignmentWithMembersAsync(classroomId, assignmentId)
            ?? throw new KeyNotFoundException("Ödev bulunamadı.");

        if (data.Assignment.Classroom.OwnerId != viewerUserId)
            throw new UnauthorizedAccessException("Yalnızca sınıf sahibi ödev detayını görebilir.");

        var assignment = data.Assignment;
        var members    = data.Members;

        var studentProgresses = members.Select(m =>
        {
            var p = assignment.Progress.FirstOrDefault(pr => pr.ChildProfileId == m.ChildProfileId);
            return new StudentProgressDto
            {
                ChildProfileId = m.ChildProfileId,
                Name           = m.ChildProfile.Name,
                CorrectCount   = p?.CompletedQuestions ?? 0,
                IsCompleted    = p?.CompletedAt != null,
                CompletedAt    = p?.CompletedAt,
            };
        }).ToList();

        return new AssignmentDetailDto
        {
            Id                = assignment.Id,
            LevelId           = assignment.LevelId,
            Title             = assignment.Title,
            TopicName         = assignment.Level?.Topic?.Name ?? string.Empty,
            SubjectName       = assignment.Level?.Topic?.Subject?.Name ?? string.Empty,
            DueDate           = assignment.DueDate,
            MinQuestions      = assignment.MinQuestions,
            StudentProgresses = studentProgresses,
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
