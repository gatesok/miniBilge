using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class UsageQuotaConfiguration : IEntityTypeConfiguration<UsageQuota>
{
    public void Configure(EntityTypeBuilder<UsageQuota> builder)
    {
        builder.ToTable("usage_quotas");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.FeatureKey).HasMaxLength(60).IsRequired();
        builder.HasIndex(x => x.FeatureKey).IsUnique();
    }
}
