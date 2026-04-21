using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class AvatarItemConfiguration : IEntityTypeConfiguration<AvatarItem>
{
    public void Configure(EntityTypeBuilder<AvatarItem> builder)
    {
        builder.ToTable("avatar_items");
        
        builder.HasKey(a => a.Id);
        
        builder.Property(a => a.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(a => a.ItemType)
            .IsRequired()
            .HasConversion<int>();
        
        builder.Property(a => a.PointCost)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(a => a.ImageUrl)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.Property(a => a.Category)
            .HasMaxLength(50);
        
        builder.Property(a => a.IsActive)
            .HasDefaultValue(true);
        
        builder.Property(a => a.CreatedAt)
            .IsRequired();
        
        builder.Property(a => a.IsDeleted)
            .HasDefaultValue(false);
        
        // Indexes
        builder.HasIndex(a => a.ItemType);
        builder.HasIndex(a => a.IsActive);
        builder.HasIndex(a => a.PointCost);
        
        // Navigation
        builder.HasMany(a => a.OwnedByChildren)
            .WithOne(o => o.Item)
            .HasForeignKey(o => o.ItemId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(a => a.EquippedByChildren)
            .WithOne(e => e.Item)
            .HasForeignKey(e => e.ItemId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
