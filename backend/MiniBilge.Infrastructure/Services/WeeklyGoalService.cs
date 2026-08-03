using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.DTOs.ParentReport;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;

namespace MiniBilge.Infrastructure.Services;

/// <summary>
/// P6-B04: Ebeveyn haftalık hedefi (çalışma dakikası + odak konu) yönetimi ve
/// mevcut haftanın ilerlemesinin hesaplanması.
/// </summary>
public class WeeklyGoalService : IWeeklyGoalService
{
    private readonly ApplicationDbContext _db;
    private readonly IProgressRepository _progressRepository;

    public WeeklyGoalService(ApplicationDbContext db, IProgressRepository progressRepository)
    {
        _db = db;
        _progressRepository = progressRepository;
    }

    public async Task<WeeklyGoalDto> GetWeeklyGoalAsync(Guid childId)
    {
        var goal = await _db.ParentWeeklyGoals
            .AsNoTracking()
            .FirstOrDefaultAsync(g => g.ChildProfileId == childId && !g.IsDeleted);

        return await BuildDtoAsync(childId, goal);
    }

    public async Task<WeeklyGoalDto> SetWeeklyGoalAsync(Guid childId, int? weeklyStudyMinutesGoal, Guid? focusTopicId)
    {
        var goal = await _db.ParentWeeklyGoals
            .FirstOrDefaultAsync(g => g.ChildProfileId == childId && !g.IsDeleted);

        if (goal == null)
        {
            goal = new ParentWeeklyGoal
            {
                Id = Guid.NewGuid(),
                ChildProfileId = childId,
                CreatedAt = DateTime.UtcNow,
            };
            _db.ParentWeeklyGoals.Add(goal);
        }

        goal.WeeklyStudyMinutesGoal = weeklyStudyMinutesGoal;
        goal.FocusTopicId = focusTopicId;
        goal.UpdatedAt = DateTime.UtcNow;

        await _db.SaveChangesAsync();

        return await BuildDtoAsync(childId, goal);
    }

    private async Task<WeeklyGoalDto> BuildDtoAsync(Guid childId, ParentWeeklyGoal? goal)
    {
        var weekStart = GetCurrentWeekMonday();
        var weekEnd = weekStart.AddDays(7);

        var attempts = await _progressRepository.GetAnswerAttemptsByDateRangeAsync(childId, weekStart, weekEnd);
        var studySeconds = attempts
            .Where(a => a.TimeTakenSeconds.HasValue)
            .Sum(a => a.TimeTakenSeconds!.Value);
        var studyMinutes = studySeconds / 60;

        string? focusTopicName = null;
        decimal? focusTopicSuccessRate = null;

        if (goal?.FocusTopicId is Guid topicId)
        {
            focusTopicName = await _db.Topics
                .AsNoTracking()
                .Where(t => t.Id == topicId)
                .Select(t => t.Name)
                .FirstOrDefaultAsync();

            var topicAttempts = attempts
                .Where(a => a.Question?.Level?.Topic?.Id == topicId)
                .ToList();

            if (topicAttempts.Count > 0)
            {
                focusTopicSuccessRate = Math.Round(
                    (decimal)topicAttempts.Count(a => a.IsCorrect) / topicAttempts.Count, 2);
            }
        }

        return new WeeklyGoalDto
        {
            ChildId = childId,
            WeeklyStudyMinutesGoal = goal?.WeeklyStudyMinutesGoal,
            FocusTopicId = goal?.FocusTopicId,
            FocusTopicName = focusTopicName,
            WeekStart = weekStart,
            WeekEnd = weekEnd,
            StudyMinutesThisWeek = studyMinutes,
            QuestionsThisWeek = attempts.Count,
            FocusTopicSuccessRate = focusTopicSuccessRate,
        };
    }

    private static DateTime GetCurrentWeekMonday()
    {
        var today = DateTime.UtcNow.Date;
        int diff = (7 + (int)today.DayOfWeek - (int)DayOfWeek.Monday) % 7;
        return today.AddDays(-diff);
    }
}
