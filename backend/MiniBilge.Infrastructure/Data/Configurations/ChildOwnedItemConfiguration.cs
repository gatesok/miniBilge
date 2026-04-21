using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class ChildOwnedItemConfiguration : IEntityTypeConfiguration<ChildOwnedItem>
{
    public void Configure(EntityTypeBuilder<ChildOwnedItem> builder)
    {
        builder.ToTable("child_owned_items");
        
        builder.HasKey(c => c.Id);
        
        builder.Property(c => c.ChildProfileId)
            .IsRequired();
        
        builder.Property(c => c.ItemId)
            .IsRequired();
        
        builder.Property(c => c.PurchasedAt)
            .IsRequired();
        
        builder.Property(c => c.CreatedAt)
            .IsRequired();
        
        builder.Property(c => c.IsDeleted)
            .HasDefaultValue(false);
        
        // Composite unique index - bir child aynı item'i sadece bir kere sahip olabilir
        builder.HasIndex(c => new { c.ChildProfileId, c.ItemId })
            .IsUnique()
            .HasFilter("\"IsDeleted\" = FALSE");
        
        // Navigation
        builder.HasOne(c => c.ChildProfile)
            .WithMany()
            .HasForeignKey(c => c.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(c => c.Item)
            .WithMany(i => i.OwnedByChildren)
            .HasForeignKey(c => c.ItemId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
