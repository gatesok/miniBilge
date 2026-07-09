using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class WordleLevelProgressConfiguration : IEntityTypeConfiguration<WordleLevelProgress>
{
    public void Configure(EntityTypeBuilder<WordleLevelProgress> builder)
    {
        builder.ToTable("wordle_level_progress");
        builder.HasKey(w => w.Id);

        builder.Property(w => w.CurrentLevel).IsRequired().HasDefaultValue(1);
        builder.Property(w => w.HighestLevel).IsRequired().HasDefaultValue(1);
        builder.Property(w => w.TotalSolved).IsRequired().HasDefaultValue(0);
        builder.Property(w => w.CurrentStreak).IsRequired().HasDefaultValue(0);
        builder.Property(w => w.BestStreak).IsRequired().HasDefaultValue(0);
        builder.Property(w => w.SkipTickets).IsRequired().HasDefaultValue(0);
        builder.Property(w => w.CreatedAt).IsRequired();

        builder.HasOne(w => w.ChildProfile)
               .WithMany()
               .HasForeignKey(w => w.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(w => w.ChildProfileId).IsUnique();

        builder.Ignore(w => w.IsDeleted);
        builder.Ignore(w => w.UpdatedAt);
    }
}
