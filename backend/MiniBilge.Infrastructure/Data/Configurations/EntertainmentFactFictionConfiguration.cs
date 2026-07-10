using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class EntertainmentFactFictionConfiguration
    : IEntityTypeConfiguration<EntertainmentFactFiction>
{
    public void Configure(EntityTypeBuilder<EntertainmentFactFiction> builder)
    {
        builder.ToTable("entertainment_fact_fiction");
        builder.HasKey(f => f.Id);
        builder.Property(f => f.Id).UseIdentityColumn();

        builder.Property(f => f.Difficulty).IsRequired();
        builder.Property(f => f.Statement).IsRequired();
        builder.Property(f => f.IsReal).IsRequired();
        builder.Property(f => f.Explanation).IsRequired();
        builder.Property(f => f.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(f => f.IsActive).IsRequired().HasDefaultValue(true);
        builder.Property(f => f.CreatedAt).HasDefaultValueSql("now()");

        builder.HasIndex(f => new { f.Difficulty, f.Language });
    }
}
