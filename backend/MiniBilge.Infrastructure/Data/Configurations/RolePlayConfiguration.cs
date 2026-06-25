using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class RolePlaySessionConfiguration : IEntityTypeConfiguration<RolePlaySession>
{
    public void Configure(EntityTypeBuilder<RolePlaySession> builder)
    {
        builder.ToTable("roleplay_sessions");
        builder.HasKey(s => s.Id);

        builder.Property(s => s.ScenarioKey).IsRequired().HasMaxLength(50);
        builder.Property(s => s.Level).IsRequired().HasMaxLength(5);
        builder.Property(s => s.Status).IsRequired().HasMaxLength(20).HasDefaultValue("active");
        builder.Property(s => s.TurnCount).IsRequired().HasDefaultValue(0);
        builder.Property(s => s.TotalScore).IsRequired(false);
        builder.Property(s => s.FinalFeedback).IsRequired(false);
        builder.Property(s => s.CreatedAt).IsRequired();
        builder.Property(s => s.CompletedAt).IsRequired(false);

        builder.HasIndex(s => s.ChildProfileId);

        builder.HasOne(s => s.ChildProfile)
               .WithMany()
               .HasForeignKey(s => s.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(s => s.Turns)
               .WithOne(t => t.Session)
               .HasForeignKey(t => t.SessionId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class RolePlayTurnConfiguration : IEntityTypeConfiguration<RolePlayTurn>
{
    public void Configure(EntityTypeBuilder<RolePlayTurn> builder)
    {
        builder.ToTable("roleplay_turns");
        builder.HasKey(t => t.Id);

        builder.Property(t => t.Role).IsRequired().HasMaxLength(10);
        builder.Property(t => t.Content).IsRequired();
        builder.Property(t => t.GrammarNote).IsRequired(false);
        builder.Property(t => t.CreatedAt).IsRequired();

        builder.HasIndex(t => t.SessionId);

        builder.HasOne(t => t.Session)
               .WithMany(s => s.Turns)
               .HasForeignKey(t => t.SessionId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class RolePlayScenarioConfiguration : IEntityTypeConfiguration<RolePlayScenario>
{
    public void Configure(EntityTypeBuilder<RolePlayScenario> builder)
    {
        builder.ToTable("roleplay_scenarios");
        builder.HasKey(s => s.Id);

        builder.Property(s => s.Key).IsRequired().HasMaxLength(50).HasColumnName("Key");
        builder.Property(s => s.Title).IsRequired().HasMaxLength(200).HasColumnName("Title");
        builder.Property(s => s.Description).IsRequired().HasMaxLength(500).HasColumnName("Description");
        builder.Property(s => s.Level).IsRequired().HasMaxLength(5).HasColumnName("Level");
        builder.Property(s => s.CharacterName).IsRequired().HasMaxLength(100).HasColumnName("CharacterName");
        builder.Property(s => s.CharacterRole).IsRequired().HasMaxLength(100).HasColumnName("CharacterRole");
        builder.Property(s => s.Emoji).IsRequired().HasMaxLength(10).HasColumnName("Emoji");
        builder.Property(s => s.OpeningLine).IsRequired().HasColumnName("OpeningLine");
        builder.Property(s => s.SystemPrompt).IsRequired().HasColumnName("SystemPrompt");
        builder.Property(s => s.IsActive).IsRequired().HasDefaultValue(true).HasColumnName("IsActive");
        builder.Property(s => s.DisplayOrder).IsRequired().HasDefaultValue(0).HasColumnName("DisplayOrder");
        builder.Property(s => s.CreatedAt).IsRequired().HasColumnName("CreatedAt");

        builder.HasIndex(s => s.Key).IsUnique();
        builder.HasIndex(s => s.Level);
    }
}
