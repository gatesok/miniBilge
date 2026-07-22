using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class AiUsageEventConfiguration : IEntityTypeConfiguration<AiUsageEvent>
{
    public void Configure(EntityTypeBuilder<AiUsageEvent> builder)
    {
        builder.ToTable("ai_usage_events");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.FeatureKey).HasMaxLength(80).IsRequired();
        builder.Property(x => x.Provider).HasMaxLength(30).IsRequired();
        builder.Property(x => x.Model).HasMaxLength(80).IsRequired();
        builder.Property(x => x.EstimatedCostUsd).HasPrecision(18, 8);
        builder.Property(x => x.ErrorCode).HasMaxLength(80);
        builder.Property(x => x.CorrelationId).HasMaxLength(64);

        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.SetNull);

        builder.HasIndex(x => x.CreatedAt);
        builder.HasIndex(x => new { x.FeatureKey, x.CreatedAt });
        builder.HasIndex(x => new { x.ChildProfileId, x.CreatedAt });
    }
}
