using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class GameStatEventConfiguration : IEntityTypeConfiguration<GameStatEvent>
{
    public void Configure(EntityTypeBuilder<GameStatEvent> builder)
    {
        builder.ToTable("game_stat_events");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.IdempotencyKey).IsRequired().HasMaxLength(100);
        builder.Property(x => x.GameType).IsRequired().HasMaxLength(20);
        builder.Property(x => x.CategoryKey).IsRequired().HasMaxLength(50).HasDefaultValue(string.Empty);
        // Aynı profil + anahtar ikinci kez işlenemez.
        builder.HasIndex(x => new { x.ChildProfileId, x.IdempotencyKey }).IsUnique();
    }
}
