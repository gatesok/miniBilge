using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class AvatarConfiguration : IEntityTypeConfiguration<Avatar>
{
    public void Configure(EntityTypeBuilder<Avatar> builder)
    {
        builder.ToTable("avatars");
        
        builder.HasKey(a => a.Id);
        
        builder.Property(a => a.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(a => a.ImageUrl)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.Property(a => a.IsDefault)
            .HasDefaultValue(false);
        
        builder.Property(a => a.IsActive)
            .HasDefaultValue(true);
        
        builder.Property(a => a.CreatedAt)
            .IsRequired();
        
        builder.Property(a => a.IsDeleted)
            .HasDefaultValue(false);
        
        // Indexes
        builder.HasIndex(a => a.IsDefault);
        builder.HasIndex(a => a.IsActive);
        
        // Navigation
        builder.HasMany(a => a.ChildProfiles)
            .WithOne()
            .HasForeignKey("AvatarId")
            .OnDelete(DeleteBehavior.Restrict);
    }
}
