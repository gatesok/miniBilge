using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class ChildEquippedItemConfiguration : IEntityTypeConfiguration<ChildEquippedItem>
{
    public void Configure(EntityTypeBuilder<ChildEquippedItem> builder)
    {
        builder.ToTable("child_equipped_items");
        
        builder.HasKey(c => c.Id);
        
        builder.Property(c => c.ChildProfileId)
            .IsRequired();
        
        builder.Property(c => c.ItemId)
            .IsRequired();
        
        builder.Property(c => c.EquippedAt)
            .IsRequired();
        
        builder.Property(c => c.CreatedAt)
            .IsRequired();
        
        builder.Property(c => c.IsDeleted)
            .HasDefaultValue(false);
        
        // Composite unique index - bir child + item sadece bir kere equipped olabilir
        builder.HasIndex(c => new { c.ChildProfileId, c.ItemId })
            .IsUnique()
            .HasFilter("\"IsDeleted\" = FALSE");
        
        // Navigation
        builder.HasOne(c => c.ChildProfile)
            .WithMany()
            .HasForeignKey(c => c.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(c => c.Item)
            .WithMany(i => i.EquippedByChildren)
            .HasForeignKey(c => c.ItemId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
