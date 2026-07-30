using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class BadgeConfiguration : IEntityTypeConfiguration<Badge>
{
    public void Configure(EntityTypeBuilder<Badge> builder)
    {
        builder.ToTable("badges");
        builder.HasKey(b => b.Id);
        builder.Property(b => b.Key).IsRequired().HasMaxLength(50);
        builder.Property(b => b.Name).IsRequired().HasMaxLength(100);
        builder.Property(b => b.Description).IsRequired();
        builder.Property(b => b.Emoji).IsRequired().HasMaxLength(10);
        builder.Property(b => b.Category).IsRequired().HasMaxLength(30);
        builder.Property(b => b.Rarity).IsRequired().HasMaxLength(20).HasDefaultValue("bronze");
        builder.HasIndex(b => b.Key).IsUnique();
    }
}

public class ChildBadgeConfiguration : IEntityTypeConfiguration<ChildBadge>
{
    public void Configure(EntityTypeBuilder<ChildBadge> builder)
    {
        builder.ToTable("child_badges");
        builder.HasKey(cb => cb.Id);
        builder.HasOne(cb => cb.ChildProfile).WithMany().HasForeignKey(cb => cb.ChildProfileId).OnDelete(DeleteBehavior.Cascade);
        builder.HasOne(cb => cb.Badge).WithMany(b => b.ChildBadges).HasForeignKey(cb => cb.BadgeId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class CollectibleCardConfiguration : IEntityTypeConfiguration<CollectibleCard>
{
    public void Configure(EntityTypeBuilder<CollectibleCard> builder)
    {
        builder.ToTable("collectible_cards");
        builder.HasKey(c => c.Id);
        builder.Property(c => c.Name).IsRequired().HasMaxLength(100);
        builder.Property(c => c.Series).IsRequired().HasMaxLength(50);
        builder.Property(c => c.Rarity).IsRequired().HasMaxLength(20).HasDefaultValue("common");
        builder.Property(c => c.ImageAsset).IsRequired();
        builder.Property(c => c.IsActive).HasDefaultValue(true);
    }
}

public class ChildCardConfiguration : IEntityTypeConfiguration<ChildCard>
{
    public void Configure(EntityTypeBuilder<ChildCard> builder)
    {
        builder.ToTable("child_cards");
        builder.HasKey(cc => cc.Id);
        builder.Property(cc => cc.Count).HasDefaultValue(1);
        builder.HasOne(cc => cc.ChildProfile).WithMany().HasForeignKey(cc => cc.ChildProfileId).OnDelete(DeleteBehavior.Cascade);
        builder.HasOne(cc => cc.Card).WithMany(c => c.ChildCards).HasForeignKey(cc => cc.CardId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class CardDropLogConfiguration : IEntityTypeConfiguration<CardDropLog>
{
    public void Configure(EntityTypeBuilder<CardDropLog> builder)
    {
        builder.ToTable("card_drop_log");
        builder.HasKey(l => l.Id);
        builder.Property(l => l.Source).IsRequired().HasMaxLength(30);
        builder.HasOne(l => l.ChildProfile).WithMany().HasForeignKey(l => l.ChildProfileId).OnDelete(DeleteBehavior.Cascade);
        builder.HasOne(l => l.Card).WithMany().HasForeignKey(l => l.CardId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class CardEconomyStateConfiguration : IEntityTypeConfiguration<CardEconomyState>
{
    public void Configure(EntityTypeBuilder<CardEconomyState> builder)
    {
        builder.ToTable("card_economy_states");
        builder.HasKey(x => x.Id);
        builder.HasIndex(x => x.ChildProfileId).IsUnique();
        builder.Property(x => x.DailyDate).HasColumnType("date");
        builder.HasOne(x => x.ChildProfile).WithMany()
            .HasForeignKey(x => x.ChildProfileId).OnDelete(DeleteBehavior.Cascade);
    }
}

public class CardEconomyEventConfiguration : IEntityTypeConfiguration<CardEconomyEvent>
{
    public void Configure(EntityTypeBuilder<CardEconomyEvent> builder)
    {
        builder.ToTable("card_economy_events");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Source).IsRequired().HasMaxLength(40);
        builder.Property(x => x.Stage).IsRequired().HasMaxLength(20);
        builder.Property(x => x.Outcome).IsRequired().HasMaxLength(30);
        builder.Property(x => x.IdempotencyKey).HasMaxLength(120);
        builder.HasIndex(x => new { x.ChildProfileId, x.IdempotencyKey })
            .IsUnique().HasFilter("\"IdempotencyKey\" IS NOT NULL");
        builder.HasIndex(x => new { x.ChildProfileId, x.CreatedAt });
    }
}
