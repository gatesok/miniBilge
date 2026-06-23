using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class PodcastQuestionConfiguration : IEntityTypeConfiguration<PodcastQuestion>
{
    public void Configure(EntityTypeBuilder<PodcastQuestion> builder)
    {
        builder.ToTable("podcast_questions");
        builder.HasKey(q => q.Id);
        builder.Property(q => q.QuestionText).IsRequired().HasMaxLength(1000);
        builder.Property(q => q.QuestionType).IsRequired();
        builder.Property(q => q.CorrectAnswer).IsRequired().HasMaxLength(500);
        builder.Property(q => q.Explanation).IsRequired(false).HasMaxLength(1000);
        builder.Property(q => q.DisplayOrder).IsRequired().HasDefaultValue(0);
        builder.Property(q => q.IsActive).IsRequired().HasDefaultValue(true);

        builder.HasIndex(q => q.EpisodeId);

        builder.HasOne(q => q.Episode)
               .WithMany(e => e.Questions)
               .HasForeignKey(q => q.EpisodeId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(q => q.Options)
               .WithOne(o => o.Question)
               .HasForeignKey(o => o.PodcastQuestionId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class PodcastQuestionOptionConfiguration : IEntityTypeConfiguration<PodcastQuestionOption>
{
    public void Configure(EntityTypeBuilder<PodcastQuestionOption> builder)
    {
        builder.ToTable("podcast_question_options");
        builder.HasKey(o => o.Id);
        builder.Property(o => o.OptionText).IsRequired().HasMaxLength(500);
        builder.Property(o => o.DisplayOrder).IsRequired().HasDefaultValue(0);

        builder.HasIndex(o => o.PodcastQuestionId);
    }
}

public class PodcastQuizResultConfiguration : IEntityTypeConfiguration<PodcastQuizResult>
{
    public void Configure(EntityTypeBuilder<PodcastQuizResult> builder)
    {
        builder.ToTable("podcast_quiz_results");
        builder.HasKey(r => r.Id);
        builder.Property(r => r.CorrectCount).IsRequired();
        builder.Property(r => r.TotalQuestions).IsRequired();
        builder.Property(r => r.StarsEarned).IsRequired().HasDefaultValue(0);
        builder.Property(r => r.CoinsEarned).IsRequired().HasDefaultValue(0);
        builder.Property(r => r.CompletedAt).IsRequired();

        // Her çocuk her bölüm için sadece 1 sonuç (tekrar oynayabilir ama üzerine yazar)
        builder.HasIndex(r => new { r.ChildProfileId, r.EpisodeId }).IsUnique();

        builder.HasOne(r => r.ChildProfile)
               .WithMany()
               .HasForeignKey(r => r.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(r => r.Episode)
               .WithMany()
               .HasForeignKey(r => r.EpisodeId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
