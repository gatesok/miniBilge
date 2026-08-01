using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class ProfileGameStatConfiguration : IEntityTypeConfiguration<ProfileGameStat>
{
    public void Configure(EntityTypeBuilder<ProfileGameStat> builder)
    {
        builder.ToTable("profile_game_stats");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.GameType).IsRequired().HasMaxLength(20);
        builder.Property(x => x.CategoryKey).IsRequired().HasMaxLength(50).HasDefaultValue(string.Empty);
        // Aynı (profil, oyun türü, kategori) için tek satır: idempotent güncelleme sağlar.
        builder.HasIndex(x => new { x.ChildProfileId, x.GameType, x.CategoryKey }).IsUnique();
        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
