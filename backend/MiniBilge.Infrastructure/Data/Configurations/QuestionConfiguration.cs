using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class QuestionConfiguration : IEntityTypeConfiguration<Question>
{
    public void Configure(EntityTypeBuilder<Question> builder)
    {
        builder.ToTable("questions");
        
        builder.HasKey(q => q.Id);
        
        builder.Property(q => q.QuestionText)
            .IsRequired()
            .HasMaxLength(1000);
        
        builder.Property(q => q.QuestionType)
            .IsRequired()
            .HasConversion<int>();
        
        builder.Property(q => q.CorrectAnswer)
            .IsRequired()
            .HasMaxLength(200);
        
        builder.Property(q => q.Explanation)
            .HasMaxLength(1000);
        
        builder.Property(q => q.DisplayOrder)
            .IsRequired();
        
        builder.Property(q => q.IsActive)
            .IsRequired()
            .HasDefaultValue(true);
        
        // Relationships
        builder.HasOne(q => q.Level)
            .WithMany(l => l.Questions)
            .HasForeignKey(q => q.LevelId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(q => q.Options)
            .WithOne(o => o.Question)
            .HasForeignKey(o => o.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
