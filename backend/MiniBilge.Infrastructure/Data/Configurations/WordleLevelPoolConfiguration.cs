using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class WordleLevelPoolConfiguration : IEntityTypeConfiguration<WordleLevelPool>
{
    public void Configure(EntityTypeBuilder<WordleLevelPool> builder)
    {
        builder.ToTable("wordle_level_pool");
        builder.HasKey(w => w.Id);

        builder.Property(w => w.Word).IsRequired().HasMaxLength(10);
        builder.Property(w => w.Hint).IsRequired();
        builder.Property(w => w.WordLength).IsRequired();
        builder.Property(w => w.Difficulty).IsRequired().HasDefaultValue(2);
        builder.Property(w => w.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(w => w.UsedCount).IsRequired().HasDefaultValue(0);
        builder.Property(w => w.CreatedAt).IsRequired();

        builder.HasIndex(w => new { w.Word, w.Language }).IsUnique();
        builder.HasIndex(w => new { w.WordLength, w.Difficulty });

        builder.Ignore(w => w.IsDeleted);
        builder.Ignore(w => w.UpdatedAt);
    }
}
