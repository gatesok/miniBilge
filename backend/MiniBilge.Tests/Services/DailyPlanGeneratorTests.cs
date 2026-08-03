using FluentAssertions;
using MiniBilge.Application.Services;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;
using Xunit;

namespace MiniBilge.Tests.Services;

// P5-B02: Standart günlük plan üreticisinin birim testleri.
public class DailyPlanGeneratorTests
{
    private readonly DailyPlanGenerator _generator = new();
    private readonly DateOnly _date = new(2026, 8, 3);

    private static ChildProfile Child(
        GradeLevel grade = GradeLevel.Grade2,
        EnglishLevel? english = EnglishLevel.A1)
        => new()
        {
            Id = Guid.NewGuid(),
            Name = "Test",
            GradeLevel = grade,
            EnglishLevel = english,
        };

    [Fact]
    public void Generate_produces_standard_pending_plan_for_date_and_child()
    {
        var child = Child();

        var plan = _generator.Generate(child, _date);

        plan.Id.Should().NotBe(Guid.Empty);
        plan.ChildProfileId.Should().Be(child.Id);
        plan.PlanDate.Should().Be(_date);
        plan.Status.Should().Be(DailyPlanStatus.Pending);
        plan.Source.Should().Be("standard");
        plan.IsPremiumPersonalized.Should().BeFalse();
    }

    [Fact]
    public void Generate_creates_math_and_vocab_items_in_order()
    {
        var plan = _generator.Generate(Child(), _date);

        plan.Items.Should().HaveCount(2);
        plan.TotalItems.Should().Be(2);
        plan.Items.Should().ContainSingle(i => i.ActivityType == "math" && i.Order == 1);
        plan.Items.Should().ContainSingle(i => i.ActivityType == "english_vocab" && i.Order == 2);
    }

    [Fact]
    public void Generate_links_items_to_plan_with_ids()
    {
        var plan = _generator.Generate(Child(), _date);

        plan.Items.Should().OnlyContain(i => i.Id != Guid.Empty && i.DailyPlanId == plan.Id);
    }

    [Fact]
    public void Generate_uses_five_math_questions_for_school_grades()
    {
        var plan = _generator.Generate(Child(GradeLevel.Grade2), _date);

        plan.Items.Single(i => i.ActivityType == "math").TargetCount.Should().Be(5);
    }

    [Fact]
    public void Generate_reduces_math_questions_for_preschool()
    {
        var plan = _generator.Generate(Child(GradeLevel.PreSchool), _date);

        plan.Items.Single(i => i.ActivityType == "math").TargetCount.Should().Be(3);
    }

    [Fact]
    public void Generate_defaults_vocab_count_when_english_level_missing()
    {
        var plan = _generator.Generate(Child(english: null), _date);

        plan.Items.Single(i => i.ActivityType == "english_vocab").TargetCount.Should().Be(5);
    }

    [Fact]
    public void Generate_increases_vocab_count_above_a1()
    {
        var plan = _generator.Generate(Child(english: EnglishLevel.B1), _date);

        plan.Items.Single(i => i.ActivityType == "english_vocab").TargetCount.Should().Be(6);
    }
}
