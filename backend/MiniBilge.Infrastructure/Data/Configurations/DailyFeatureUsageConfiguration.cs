using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class DailyFeatureUsageConfiguration
    : IEntityTypeConfiguration<DailyFeatureUsage>
{
    public void Configure(EntityTypeBuilder<DailyFeatureUsage> builder)
    {
        builder.ToTable("daily_feature_usages");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.FeatureKey).HasMaxLength(60).IsRequired();
        builder.Property(x => x.UsageDate).HasColumnType("date").IsRequired();
        builder.HasIndex(x => new
        {
            x.ChildProfileId,
            x.FeatureKey,
            x.UsageDate,
        }).IsUnique();
        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
