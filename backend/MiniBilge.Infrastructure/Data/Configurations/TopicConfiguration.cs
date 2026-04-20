using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class TopicConfiguration : IEntityTypeConfiguration<Topic>
{
    public void Configure(EntityTypeBuilder<Topic> builder)
    {
        builder.ToTable("topics");
        
        builder.HasKey(t => t.Id);
        
        builder.Property(t => t.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(t => t.Description)
            .HasMaxLength(500);
        
        builder.Property(t => t.DisplayOrder)
            .IsRequired();
        
        builder.Property(t => t.IsActive)
            .IsRequired()
            .HasDefaultValue(true);
        
        // Relationships
        builder.HasOne(t => t.Subject)
            .WithMany(s => s.Topics)
            .HasForeignKey(t => t.SubjectId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(t => t.Levels)
            .WithOne(l => l.Topic)
            .HasForeignKey(l => l.TopicId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
