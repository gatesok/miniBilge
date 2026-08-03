using FluentAssertions;
using MiniBilge.Application.DTOs.ParentReport;
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

    // ── P6: kişiselleştirilmiş plan ──────────────────────────────

    private static WeakTopicDto Weak(string topic, string subject, decimal rate)
        => new()
        {
            TopicId = Guid.NewGuid(),
            TopicName = topic,
            SubjectName = subject,
            TotalAttempts = 10,
            CorrectAttempts = (int)(rate * 10),
            SuccessRate = rate,
        };

    [Fact]
    public void GeneratePersonalized_marks_plan_as_premium_personalized()
    {
        var weak = new List<WeakTopicDto> { Weak("Kesirler", "Matematik", 0.3m) };

        var plan = _generator.GeneratePersonalized(Child(), _date, weak);

        plan.Source.Should().Be("personalized");
        plan.IsPremiumPersonalized.Should().BeTrue();
        plan.Status.Should().Be(DailyPlanStatus.Pending);
    }

    [Fact]
    public void GeneratePersonalized_focuses_math_and_english_items_on_weak_topics()
    {
        var mathTopic = Weak("Kesirler", "Matematik", 0.3m);
        var englishTopic = Weak("Fiiller", "İngilizce", 0.5m);
        var weak = new List<WeakTopicDto> { mathTopic, englishTopic };

        var plan = _generator.GeneratePersonalized(Child(), _date, weak);

        var math = plan.Items.Single(i => i.ActivityType == "math");
        math.Title.Should().Contain("Kesirler");
        math.RouteKey.Should().Be($"topic:{mathTopic.TopicId}");

        var english = plan.Items.Single(i => i.ActivityType == "english_vocab");
        english.Title.Should().Contain("Fiiller");
        english.RouteKey.Should().Be($"topic:{englishTopic.TopicId}");
    }

    [Fact]
    public void GeneratePersonalized_fills_note_explaining_weak_topic()
    {
        var mathTopic = Weak("Kesirler", "Matematik", 0.3m);
        var weak = new List<WeakTopicDto> { mathTopic };

        var plan = _generator.GeneratePersonalized(Child(), _date, weak);

        var math = plan.Items.Single(i => i.ActivityType == "math");
        math.Note.Should().NotBeNullOrEmpty();
        math.Note.Should().Contain("Kesirler");
        math.Note.Should().Contain("%30");
    }

    [Fact]
    public void GeneratePersonalized_adds_reinforcement_item_for_weakest_topic()
    {
        var weakest = Weak("Kesirler", "Matematik", 0.2m);
        var weak = new List<WeakTopicDto> { weakest, Weak("Fiiller", "İngilizce", 0.5m) };

        var plan = _generator.GeneratePersonalized(Child(), _date, weak);

        plan.Items.Should().HaveCount(3);
        var reinforcement = plan.Items.Single(i => i.ActivityType == "flashcard");
        reinforcement.Order.Should().Be(3);
        reinforcement.Title.Should().Contain("Kesirler");
        reinforcement.RouteKey.Should().Be($"topic:{weakest.TopicId}");
        reinforcement.Note.Should().NotBeNullOrEmpty();
    }

    [Fact]
    public void GeneratePersonalized_uses_generic_titles_when_subject_not_matched()
    {
        // Sadece eşleşmeyen bir konu — matematik/İngilizce başlıkları jenerik olmalı ama
        // en zayıf konu için pekiştirme maddesi yine eklenir.
        var weak = new List<WeakTopicDto> { Weak("Genel Kültür", "Bilim", 0.4m) };

        var plan = _generator.GeneratePersonalized(Child(), _date, weak);

        plan.Items.Single(i => i.ActivityType == "math").Title.Should().Contain("Özel");
        plan.Items.Single(i => i.ActivityType == "english_vocab").Title.Should().Contain("Özel");
        plan.Items.Should().Contain(i => i.ActivityType == "flashcard");
    }
}
