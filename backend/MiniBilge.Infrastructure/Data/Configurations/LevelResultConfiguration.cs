using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class LevelResultConfiguration : IEntityTypeConfiguration<LevelResult>
{
    public void Configure(EntityTypeBuilder<LevelResult> builder)
    {
        builder.ToTable("level_results");
        
        builder.HasKey(lr => lr.Id);
        
        builder.Property(lr => lr.Score)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(lr => lr.Stars)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(lr => lr.CorrectCount)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(lr => lr.TotalQuestions)
            .IsRequired()
            .HasDefaultValue(0);
        
        builder.Property(lr => lr.SuccessPercentage)
            .IsRequired()
            .HasPrecision(5, 2) // 999.99
            .HasDefaultValue(0);
        
        builder.Property(lr => lr.IsUnlocked)
            .IsRequired()
            .HasDefaultValue(false);
        
        builder.Property(lr => lr.CompletedAt)
            .IsRequired(false);
        
        // Relationships
        builder.HasOne(lr => lr.Child)
            .WithMany()
            .HasForeignKey(lr => lr.ChildId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(lr => lr.Level)
            .WithMany()
            .HasForeignKey(lr => lr.LevelId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Indexes
        builder.HasIndex(lr => lr.ChildId);
        builder.HasIndex(lr => lr.LevelId);
        builder.HasIndex(lr => new { lr.ChildId, lr.LevelId })
            .IsUnique(); // Her child için her level'ın bir sonucu olur
        builder.HasIndex(lr => lr.CompletedAt);
    }
}
