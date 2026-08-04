using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class ParentWeeklyGoalConfiguration : IEntityTypeConfiguration<ParentWeeklyGoal>
{
    public void Configure(EntityTypeBuilder<ParentWeeklyGoal> builder)
    {
        builder.ToTable("parent_weekly_goals");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.FocusCategoryKey).HasMaxLength(64);

        // Çocuk başına tek hedef satırı.
        builder.HasIndex(x => x.ChildProfileId).IsUnique();

        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
