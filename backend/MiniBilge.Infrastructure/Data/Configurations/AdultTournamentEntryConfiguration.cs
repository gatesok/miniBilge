using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public sealed class AdultTournamentEntryConfiguration : IEntityTypeConfiguration<AdultTournamentEntry>
{
    public void Configure(EntityTypeBuilder<AdultTournamentEntry> builder)
    {
        builder.ToTable("adult_tournament_entries");
        builder.HasKey(x => x.Id);

        builder.Property(x => x.CategoryKey).HasMaxLength(64).IsRequired();

        // (çocuk, hafta, kategori) başına tek satır (upsert).
        builder.HasIndex(x => new { x.ChildProfileId, x.WeekStart, x.CategoryKey }).IsUnique();

        // Haftalık kategori sıralaması sorgusu için.
        builder.HasIndex(x => new { x.WeekStart, x.CategoryKey });

        builder.HasOne(x => x.ChildProfile)
            .WithMany()
            .HasForeignKey(x => x.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
