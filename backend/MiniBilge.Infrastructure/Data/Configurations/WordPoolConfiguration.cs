using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class WordPoolConfiguration : IEntityTypeConfiguration<WordPool>
{
    public void Configure(EntityTypeBuilder<WordPool> builder)
    {
        builder.ToTable("word_pool");
        builder.HasKey(w => w.Id);

        builder.Property(w => w.Word).IsRequired().HasMaxLength(10);
        builder.Property(w => w.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(w => w.Hint);
        builder.Property(w => w.Difficulty).IsRequired().HasDefaultValue(2);
        builder.Property(w => w.Source).IsRequired().HasMaxLength(20).HasDefaultValue("manual");
        builder.Property(w => w.UsedOn);
        builder.Property(w => w.CreatedAt).IsRequired();

        builder.HasIndex(w => new { w.Word, w.Language }).IsUnique();
        builder.HasIndex(w => new { w.Language, w.UsedOn });

        // BaseEntity alanları — bu tabloda IsDeleted/UpdatedAt kullanmıyoruz
        builder.Ignore(w => w.IsDeleted);
        builder.Ignore(w => w.UpdatedAt);
    }
}
