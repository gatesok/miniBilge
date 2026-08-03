using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class DailyPlanConfiguration : IEntityTypeConfiguration<DailyPlan>
{
    public void Configure(EntityTypeBuilder<DailyPlan> builder)
    {
        builder.ToTable("daily_plans");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.PlanDate).HasColumnType("date").IsRequired();
        builder.Property(x => x.Source).HasMaxLength(30).IsRequired();

        builder.HasIndex(x => new { x.ChildProfileId, x.PlanDate }).IsUnique();

        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasMany(x => x.Items)
            .WithOne(x => x.DailyPlan)
            .HasForeignKey(x => x.DailyPlanId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
