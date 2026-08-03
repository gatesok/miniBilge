using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class UsageEventConfiguration : IEntityTypeConfiguration<UsageEvent>
{
    public void Configure(EntityTypeBuilder<UsageEvent> builder)
    {
        builder.ToTable("usage_events");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.FeatureKey).HasMaxLength(60).IsRequired();
        builder.Property(x => x.EventType).HasMaxLength(30).IsRequired();
        builder.Property(x => x.UsageDate).HasColumnType("date").IsRequired();
        builder.Property(x => x.IdempotencyKey).HasMaxLength(100);
        builder.HasIndex(x => new { x.ChildProfileId, x.FeatureKey, x.UsageDate });
        // NULL idempotency key'ler kısıtlanmaz; dolu olanlar tekildir (replay koruması).
        builder.HasIndex(x => x.IdempotencyKey)
            .IsUnique()
            .HasFilter("\"IdempotencyKey\" IS NOT NULL");
    }
}
