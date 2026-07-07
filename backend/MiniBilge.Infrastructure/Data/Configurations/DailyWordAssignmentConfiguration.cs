using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class DailyWordAssignmentConfiguration : IEntityTypeConfiguration<DailyWordAssignment>
{
    public void Configure(EntityTypeBuilder<DailyWordAssignment> builder)
    {
        builder.ToTable("daily_word_assignment");
        builder.HasKey(d => d.Date);

        builder.Property(d => d.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(d => d.CreatedAt).IsRequired();

        builder.HasOne(d => d.WordPool)
               .WithMany()
               .HasForeignKey(d => d.WordPoolId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(d => d.Date);
    }
}
