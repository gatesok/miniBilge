using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class DailyPlanItemConfiguration : IEntityTypeConfiguration<DailyPlanItem>
{
    public void Configure(EntityTypeBuilder<DailyPlanItem> builder)
    {
        builder.ToTable("daily_plan_items");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.ActivityType).HasMaxLength(40).IsRequired();
        builder.Property(x => x.Title).HasMaxLength(120).IsRequired();
        builder.Property(x => x.RouteKey).HasMaxLength(120);

        builder.HasIndex(x => new { x.DailyPlanId, x.Order });
    }
}
