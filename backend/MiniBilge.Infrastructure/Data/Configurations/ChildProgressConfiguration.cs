using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class ChildProgressConfiguration : IEntityTypeConfiguration<ChildProgress>
{
    public void Configure(EntityTypeBuilder<ChildProgress> builder)
    {
        builder.ToTable("child_progress");
        
        builder.HasKey(cp => cp.Id);
        
        builder.Property(cp => cp.TotalScore)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(cp => cp.TotalStars)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(cp => cp.CompletedLevelsCount)
            .IsRequired()
            .HasDefaultValue(0);
        
        // Relationships
        builder.HasOne(cp => cp.Child)
            .WithMany()
            .HasForeignKey(cp => cp.ChildId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Indexes
        builder.HasIndex(cp => cp.ChildId)
            .IsUnique(); // Her child için tek bir progress kaydı
    }
}
