using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class EntertainmentActivityConfiguration : IEntityTypeConfiguration<EntertainmentActivity>
{
    public void Configure(EntityTypeBuilder<EntertainmentActivity> builder)
    {
        builder.ToTable("entertainment_activities");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.CategoryKey).HasMaxLength(64);
        builder.Property(x => x.IdempotencyKey).HasMaxLength(128);

        // Haftalık pencere sorgusu: çocuk + tamamlanma zamanı.
        builder.HasIndex(x => new { x.ChildProfileId, x.CompletedAt });

        // Aynı sonuç iki kez kaydedilmesin (idempotency anahtarı doluysa).
        builder.HasIndex(x => new { x.ChildProfileId, x.IdempotencyKey })
            .IsUnique()
            .HasFilter("\"IdempotencyKey\" IS NOT NULL");

        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
