using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class LevelConfiguration : IEntityTypeConfiguration<Level>
{
    public void Configure(EntityTypeBuilder<Level> builder)
    {
        builder.ToTable("levels");
        
        builder.HasKey(l => l.Id);
        
        builder.Property(l => l.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(l => l.Description)
            .HasMaxLength(500);
        
        builder.Property(l => l.Difficulty)
            .IsRequired();
        
        builder.Property(l => l.DisplayOrder)
            .IsRequired();
        
        builder.Property(l => l.MinCorrectToPass)
            .IsRequired()
            .HasDefaultValue(7);
        
        builder.Property(l => l.IsActive)
            .IsRequired()
            .HasDefaultValue(true);
        
        // Relationships
        builder.HasOne(l => l.Topic)
            .WithMany(t => t.Levels)
            .HasForeignKey(l => l.TopicId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(l => l.Questions)
            .WithOne(q => q.Level)
            .HasForeignKey(q => q.LevelId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
