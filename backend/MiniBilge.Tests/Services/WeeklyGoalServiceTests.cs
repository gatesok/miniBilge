using FluentAssertions;
using Microsoft.EntityFrameworkCore;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Entities;
using MiniBilge.Infrastructure.Data;
using MiniBilge.Infrastructure.Services;
using Moq;
using Xunit;

namespace MiniBilge.Tests.Services;

// P6-B04: Ebeveyn haftalık hedefi (upsert + mevcut hafta ilerlemesi) testleri.
public class WeeklyGoalServiceTests : IDisposable
{
    private readonly ApplicationDbContext _context;
    private readonly Mock<IProgressRepository> _progressRepository = new();
    private readonly Mock<IAdultTournamentService> _tournamentService = new();
    private readonly WeeklyGoalService _service;
    private static readonly Guid ChildId = Guid.NewGuid();

    public WeeklyGoalServiceTests()
    {
        var options = new DbContextOptionsBuilder<ApplicationDbContext>()
            .UseInMemoryDatabase(databaseName: Guid.NewGuid().ToString())
            .Options;
        _context = new ApplicationDbContext(options);

        _progressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>());

        _service = new WeeklyGoalService(_context, _progressRepository.Object, _tournamentService.Object);
    }

    public void Dispose()
    {
        _context.Database.EnsureDeleted();
        _context.Dispose();
    }

    [Fact]
    public async Task GetWeeklyGoal_WhenNoGoalSet_ShouldReturnNullGoalFields()
    {
        var result = await _service.GetWeeklyGoalAsync(ChildId);

        result.ChildId.Should().Be(ChildId);
        result.WeeklyStudyMinutesGoal.Should().BeNull();
        result.FocusTopicId.Should().BeNull();
    }

    [Fact]
    public async Task SetWeeklyGoal_ShouldInsertThenUpdateSameRow()
    {
        await _service.SetWeeklyGoalAsync(ChildId, 120, null, null);
        var updated = await _service.SetWeeklyGoalAsync(ChildId, 200, null, null);

        updated.WeeklyStudyMinutesGoal.Should().Be(200);
        // Upsert → tek satır kalmalı.
        (await _context.ParentWeeklyGoals.CountAsync(g => g.ChildProfileId == ChildId))
            .Should().Be(1);
    }

    [Fact]
    public async Task GetWeeklyGoal_ShouldComputeStudyMinutesAndQuestionsThisWeek()
    {
        _progressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>
            {
                new() { IsCorrect = true, TimeTakenSeconds = 90 },
                new() { IsCorrect = false, TimeTakenSeconds = 30 },
                new() { IsCorrect = true, TimeTakenSeconds = null },
            });

        var result = await _service.GetWeeklyGoalAsync(ChildId);

        result.QuestionsThisWeek.Should().Be(3);
        result.StudyMinutesThisWeek.Should().Be(2); // (90+30)/60
    }

    [Fact]
    public async Task GetWeeklyGoal_WithFocusTopic_ShouldResolveNameAndSuccessRate()
    {
        var subject = new Subject { Id = Guid.NewGuid(), Name = "Matematik" };
        var topic = new Topic { Id = Guid.NewGuid(), Name = "Kesirler", Subject = subject };
        _context.Topics.Add(topic);
        await _context.SaveChangesAsync();

        var q = new Question { Level = new Level { Topic = topic } };
        _progressRepository
            .Setup(r => r.GetAnswerAttemptsByDateRangeAsync(It.IsAny<Guid>(), It.IsAny<DateTime>(), It.IsAny<DateTime>()))
            .ReturnsAsync(new List<AnswerAttempt>
            {
                new() { Question = q, IsCorrect = true, TimeTakenSeconds = 60 },
                new() { Question = q, IsCorrect = false, TimeTakenSeconds = 60 },
            });

        await _service.SetWeeklyGoalAsync(ChildId, 100, topic.Id, null);
        var result = await _service.GetWeeklyGoalAsync(ChildId);

        result.FocusTopicId.Should().Be(topic.Id);
        result.FocusTopicName.Should().Be("Kesirler");
        result.FocusTopicSuccessRate.Should().Be(0.50m);
    }
}
