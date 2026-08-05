using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class TdkWordCacheConfiguration : IEntityTypeConfiguration<TdkWordCache>
{
    public void Configure(EntityTypeBuilder<TdkWordCache> builder)
    {
        builder.ToTable("tdk_word_cache");
        builder.HasKey(w => w.Id);

        builder.Property(w => w.Word).IsRequired().HasMaxLength(64);
        builder.Property(w => w.IsValid).IsRequired();
        builder.Property(w => w.CheckedAt).IsRequired();
        builder.Property(w => w.CreatedAt).IsRequired();

        builder.HasIndex(w => w.Word).IsUnique();

        builder.Ignore(w => w.IsDeleted);
        builder.Ignore(w => w.UpdatedAt);
    }
}
