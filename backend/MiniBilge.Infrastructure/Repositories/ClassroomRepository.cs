using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class ClassroomRepository : IClassroomRepository
{
    private readonly ApplicationDbContext _db;

    public ClassroomRepository(ApplicationDbContext db) => _db = db;

    // ── Classroom CRUD ────────────────────────────────────────────────────────

    public async Task<Classroom> CreateAsync(Guid ownerId, string name, string inviteCode)
    {
        var classroom = new Classroom
        {
            OwnerId    = ownerId,
            Name       = name,
            InviteCode = inviteCode,
            CreatedAt  = DateTime.UtcNow,
        };
        _db.Classrooms.Add(classroom);
        await _db.SaveChangesAsync();
        return classroom;
    }

    public Task<Classroom?> GetByIdAsync(Guid id)
        => _db.Classrooms
            .Include(c => c.Members).ThenInclude(m => m.ChildProfile)
            .Include(c => c.Assignments).ThenInclude(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(c => c.Assignments).ThenInclude(a => a.Progress)
            .FirstOrDefaultAsync(c => c.Id == id && !c.IsDeleted);

    public Task<Classroom?> GetByInviteCodeAsync(string inviteCode)
        => _db.Classrooms
            .FirstOrDefaultAsync(c => c.InviteCode == inviteCode && !c.IsDeleted);

    public Task<List<Classroom>> GetByOwnerAsync(Guid ownerId)
        => _db.Classrooms
            .Include(c => c.Members)
            .Include(c => c.Assignments).ThenInclude(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(c => c.Assignments).ThenInclude(a => a.Progress)
            .Where(c => c.OwnerId == ownerId && !c.IsDeleted)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

    public Task<List<Classroom>> GetByMemberAsync(Guid childProfileId)
    {
        var classroomIds = _db.ClassroomMembers
            .Where(m => m.ChildProfileId == childProfileId)
            .Select(m => m.ClassroomId);

        return _db.Classrooms
            .Include(c => c.Members)
            .Include(c => c.Assignments).ThenInclude(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(c => c.Assignments).ThenInclude(a => a.Progress)
            .Where(c => classroomIds.Contains(c.Id) && !c.IsDeleted)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();
    }

    // ── Members ───────────────────────────────────────────────────────────────

    public async Task AddMemberAsync(Guid classroomId, Guid childProfileId)
    {
        _db.ClassroomMembers.Add(new ClassroomMember
        {
            ClassroomId    = classroomId,
            ChildProfileId = childProfileId,
            Role           = ClassroomRole.Student,
            JoinedAt       = DateTime.UtcNow,
        });
        await _db.SaveChangesAsync();
    }

    public async Task RemoveMemberAsync(Guid classroomId, Guid childProfileId)
    {
        var member = await _db.ClassroomMembers
            .FirstOrDefaultAsync(m => m.ClassroomId == classroomId && m.ChildProfileId == childProfileId);
        if (member != null)
        {
            _db.ClassroomMembers.Remove(member);
            await _db.SaveChangesAsync();
        }
    }

    public Task<bool> IsMemberAsync(Guid classroomId, Guid childProfileId)
        => _db.ClassroomMembers
            .AnyAsync(m => m.ClassroomId == classroomId && m.ChildProfileId == childProfileId);

    public Task<List<ClassroomMember>> GetMembersAsync(Guid classroomId)
        => _db.ClassroomMembers
            .Include(m => m.ChildProfile)
            .Where(m => m.ClassroomId == classroomId)
            .ToListAsync();

    // ── Assignments ───────────────────────────────────────────────────────────

    public async Task<ClassroomAssignment> CreateAssignmentAsync(
        Guid classroomId, Guid levelId, string title, DateTime? dueDate, int minQuestions)
    {
        var assignment = new ClassroomAssignment
        {
            ClassroomId  = classroomId,
            LevelId      = levelId,
            Title        = title,
            DueDate      = dueDate,
            MinQuestions = minQuestions,
            CreatedAt    = DateTime.UtcNow,
        };
        _db.ClassroomAssignments.Add(assignment);
        await _db.SaveChangesAsync();
        return assignment;
    }

    public Task<List<ClassroomAssignment>> GetAssignmentsAsync(Guid classroomId)
        => _db.ClassroomAssignments
            .Include(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(a => a.Progress)
            .Where(a => a.ClassroomId == classroomId && !a.IsDeleted)
            .OrderByDescending(a => a.CreatedAt)
            .ToListAsync();

    public Task<ClassroomAssignment?> GetAssignmentByIdAsync(Guid assignmentId)
        => _db.ClassroomAssignments
            .Include(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(a => a.Progress)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && !a.IsDeleted);

    public Task<ClassroomAssignment?> GetActiveAssignmentForChildAsync(Guid childProfileId, Guid levelId)
    {
        var memberClassroomIds = _db.ClassroomMembers
            .Where(m => m.ChildProfileId == childProfileId)
            .Select(m => m.ClassroomId);

        return _db.ClassroomAssignments
            .Include(a => a.Progress)
            .Where(a =>
                !a.IsDeleted &&
                a.LevelId == levelId &&
                (a.DueDate == null || a.DueDate > DateTime.UtcNow) &&
                memberClassroomIds.Contains(a.ClassroomId) &&
                !a.Progress.Any(p => p.ChildProfileId == childProfileId && p.CompletedAt != null))
            .FirstOrDefaultAsync();
    }

    // ── Progress ──────────────────────────────────────────────────────────────

    public Task<AssignmentProgress?> GetProgressAsync(Guid assignmentId, Guid childProfileId)
        => _db.AssignmentProgresses
            .FirstOrDefaultAsync(p => p.AssignmentId == assignmentId && p.ChildProfileId == childProfileId);

    public async Task UpsertProgressAsync(
        Guid assignmentId, Guid childProfileId, int completedQuestions, bool isCompleted)
    {
        var progress = await GetProgressAsync(assignmentId, childProfileId);

        if (progress == null)
        {
            _db.AssignmentProgresses.Add(new AssignmentProgress
            {
                AssignmentId       = assignmentId,
                ChildProfileId     = childProfileId,
                CompletedQuestions = completedQuestions,
                CompletedAt        = isCompleted ? DateTime.UtcNow : null,
                UpdatedAt          = DateTime.UtcNow,
            });
        }
        else
        {
            progress.CompletedQuestions = Math.Max(progress.CompletedQuestions, completedQuestions);
            if (isCompleted && progress.CompletedAt == null)
                progress.CompletedAt = DateTime.UtcNow;
            progress.UpdatedAt = DateTime.UtcNow;
            _db.AssignmentProgresses.Update(progress);
        }

        await _db.SaveChangesAsync();
    }

    public async Task<(ClassroomAssignment Assignment, List<ClassroomMember> Members)?> GetAssignmentWithMembersAsync(Guid classroomId, Guid assignmentId)
    {
        var assignment = await _db.ClassroomAssignments
            .Include(a => a.Classroom)
            .Include(a => a.Level).ThenInclude(l => l.Topic).ThenInclude(t => t.Subject)
            .Include(a => a.Progress).ThenInclude(p => p.ChildProfile)
            .FirstOrDefaultAsync(a => a.Id == assignmentId && a.ClassroomId == classroomId && !a.IsDeleted);

        if (assignment == null) return null;

        var members = await _db.ClassroomMembers
            .Include(m => m.ChildProfile)
            .Where(m => m.ClassroomId == classroomId)
            .ToListAsync();

        return (assignment, members);
    }

    public Task<bool> InviteCodeExistsAsync(string code)
        => _db.Classrooms.AnyAsync(c => c.InviteCode == code && !c.IsDeleted);

    // ── Silme / Güncelleme ────────────────────────────────────────────────────

    public async Task DeleteClassroomAsync(Guid classroomId)
    {
        var classroom = await _db.Classrooms.FindAsync(classroomId);
        if (classroom is null) return;
        classroom.IsDeleted = true;
        classroom.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    public async Task DeleteAssignmentAsync(Guid assignmentId)
    {
        var assignment = await _db.ClassroomAssignments.FindAsync(assignmentId);
        if (assignment is null) return;
        assignment.IsDeleted = true;
        assignment.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    public async Task UpdateAssignmentAsync(ClassroomAssignment assignment)
    {
        assignment.UpdatedAt = DateTime.UtcNow;
        await _db.SaveChangesAsync();
    }

    // ── Ödev hatırlatma sorgusu ───────────────────────────────────────────────

    public async Task<List<MiniBilge.Application.DTOs.Classroom.AssignmentReminderData>>
        GetAssignmentsDueTomorrowWithPendingMembersAsync()
    {
        var tomorrowStart = DateTime.UtcNow.Date.AddDays(1);
        var tomorrowEnd   = tomorrowStart.AddDays(1);

        var assignments = await _db.ClassroomAssignments
            .Include(a => a.Classroom).ThenInclude(c => c.Members)
            .Include(a => a.Progress)
            .Where(a =>
                !a.IsDeleted &&
                a.DueDate >= tomorrowStart &&
                a.DueDate <  tomorrowEnd)
            .ToListAsync();

        return assignments.Select(a =>
        {
            var completedIds = a.Progress
                .Where(p => p.CompletedAt != null)
                .Select(p => p.ChildProfileId)
                .ToHashSet();

            var pending = a.Classroom.Members
                .Select(m => m.ChildProfileId)
                .Where(id => !completedIds.Contains(id))
                .ToList();

            return new MiniBilge.Application.DTOs.Classroom.AssignmentReminderData
            {
                AssignmentId    = a.Id,
                Title           = a.Title,
                ClassroomName   = a.Classroom.Name,
                DueDate         = a.DueDate!.Value,
                PendingChildIds = pending,
            };
        }).ToList();
    }

    public async Task<Dictionary<Guid, int>> GetMemberCompletedCountsAsync(Guid classroomId)
    {
        // Doğrudan DB sorgusu — include chain'e güvenmez
        var assignmentIds = await _db.ClassroomAssignments
            .Where(a => a.ClassroomId == classroomId && !a.IsDeleted)
            .Select(a => a.Id)
            .ToListAsync();

        return await _db.AssignmentProgresses
            .Where(p => assignmentIds.Contains(p.AssignmentId) && p.CompletedAt != null)
            .GroupBy(p => p.ChildProfileId)
            .Select(g => new { ChildProfileId = g.Key, Count = g.Count() })
            .ToDictionaryAsync(x => x.ChildProfileId, x => x.Count);
    }

    public async Task<Dictionary<Guid, (int CompletedBy, int AverageCorrectCount)>> GetAssignmentCompletedStatsAsync(Guid classroomId)
    {
        // Doğrudan DB sorgusu — include chain'e güvenmez
        var assignmentIds = await _db.ClassroomAssignments
            .Where(a => a.ClassroomId == classroomId && !a.IsDeleted)
            .Select(a => a.Id)
            .ToListAsync();

        var groups = await _db.AssignmentProgresses
            .Where(p => assignmentIds.Contains(p.AssignmentId) && p.CompletedAt != null)
            .GroupBy(p => p.AssignmentId)
            .Select(g => new
            {
                AssignmentId        = g.Key,
                CompletedBy         = g.Count(),
                AverageCorrectCount = (int)Math.Round(g.Average(p => (double)p.CompletedQuestions)),
            })
            .ToListAsync();

        // Tüm assignmentId'leri 0 varsayılan ile başlat, sonra gerçek verilerle doldur
        var result = assignmentIds.ToDictionary(id => id, _ => (CompletedBy: 0, AverageCorrectCount: 0));
        foreach (var g in groups)
            result[g.AssignmentId] = (g.CompletedBy, g.AverageCorrectCount);
        return result;
    }
}
