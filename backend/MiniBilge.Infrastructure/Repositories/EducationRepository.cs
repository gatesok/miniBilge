using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Repositories;

public class EducationRepository : IEducationRepository
{
    private readonly ApplicationDbContext _context;

    public EducationRepository(ApplicationDbContext context)
    {
        _context = context;
    }

    public async Task<List<Subject>> GetAllSubjectsAsync(CancellationToken cancellationToken = default)
    {
        return await _context.Subjects
            .Where(s => s.IsActive && !s.IsDeleted)
            .OrderBy(s => s.DisplayOrder)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<Topic>> GetTopicsBySubjectIdAsync(Guid subjectId, CancellationToken cancellationToken = default)
    {
        return await _context.Topics
            .Where(t => t.SubjectId == subjectId && t.IsActive && !t.IsDeleted)
            .OrderBy(t => t.DisplayOrder)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<Level>> GetLevelsByTopicIdAsync(Guid topicId, CancellationToken cancellationToken = default)
    {
        return await _context.Levels
            .Where(l => l.TopicId == topicId && l.IsActive && !l.IsDeleted)
            .OrderBy(l => l.DisplayOrder)
            .ToListAsync(cancellationToken);
    }

    public async Task<List<Question>> GetQuestionsByLevelIdAsync(Guid levelId, CancellationToken cancellationToken = default)
    {
        return await _context.Questions
            .Where(q => q.LevelId == levelId && q.IsActive && !q.IsDeleted)
            .Include(q => q.Options)
            .ToListAsync(cancellationToken);
    }

    public async Task<Question?> GetQuestionByIdAsync(Guid questionId, CancellationToken cancellationToken = default)
    {
        return await _context.Questions
            .FirstOrDefaultAsync(q => q.Id == questionId && !q.IsDeleted, cancellationToken);
    }
}
