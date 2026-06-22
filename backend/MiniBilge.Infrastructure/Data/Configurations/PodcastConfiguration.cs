using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class PodcastEpisodeConfiguration : IEntityTypeConfiguration<PodcastEpisode>
{
    public void Configure(EntityTypeBuilder<PodcastEpisode> builder)
    {
        builder.ToTable("podcast_episodes");
        builder.HasKey(e => e.Id);
        builder.Property(e => e.Title).IsRequired().HasMaxLength(200);
        builder.Property(e => e.Description).IsRequired();
        builder.Property(e => e.EnglishLevel).IsRequired();
        builder.Property(e => e.DisplayOrder).IsRequired().HasDefaultValue(0);
        builder.Property(e => e.IsActive).IsRequired().HasDefaultValue(true);
        builder.HasIndex(e => e.EnglishLevel);
        builder.HasMany(e => e.Lines)
               .WithOne(l => l.Episode)
               .HasForeignKey(l => l.EpisodeId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class PodcastLineConfiguration : IEntityTypeConfiguration<PodcastLine>
{
    public void Configure(EntityTypeBuilder<PodcastLine> builder)
    {
        builder.ToTable("podcast_lines");
        builder.HasKey(l => l.Id);
        builder.Property(l => l.SpeakerName).IsRequired().HasMaxLength(50);
        builder.Property(l => l.SpeakerGender).IsRequired();
        builder.Property(l => l.Text).IsRequired();
        builder.Property(l => l.TranslationTr).IsRequired(false);
        builder.Property(l => l.DisplayOrder).IsRequired().HasDefaultValue(0);
        builder.Property(l => l.AudioUrl).HasColumnName("audio_url").IsRequired(false);
        builder.Property(l => l.VoiceKey).HasColumnName("voice_key").IsRequired(false).HasMaxLength(20);
        builder.HasIndex(l => l.EpisodeId);
    }
}
