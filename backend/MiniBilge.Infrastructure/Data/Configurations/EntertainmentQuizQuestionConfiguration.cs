using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class EntertainmentQuizQuestionConfiguration
    : IEntityTypeConfiguration<EntertainmentQuizQuestion>
{
    public void Configure(EntityTypeBuilder<EntertainmentQuizQuestion> builder)
    {
        builder.ToTable("entertainment_quiz");
        builder.HasKey(q => q.Id);
        builder.Property(q => q.Id).UseIdentityColumn();

        builder.Property(q => q.CategoryKey).IsRequired().HasMaxLength(50);
        builder.Property(q => q.Difficulty).IsRequired();
        builder.Property(q => q.QuestionText).IsRequired();
        builder.Property(q => q.OptionA).IsRequired().HasMaxLength(500);
        builder.Property(q => q.OptionB).IsRequired().HasMaxLength(500);
        builder.Property(q => q.OptionC).IsRequired().HasMaxLength(500);
        builder.Property(q => q.OptionD).IsRequired().HasMaxLength(500);
        builder.Property(q => q.CorrectAnswer).IsRequired().HasMaxLength(1);
        builder.Property(q => q.Explanation);
        builder.Property(q => q.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(q => q.IsActive).IsRequired().HasDefaultValue(true);
        builder.Property(q => q.CreatedAt).HasDefaultValueSql("now()");

        builder.HasIndex(q => new { q.CategoryKey, q.Difficulty, q.Language });
    }
}
