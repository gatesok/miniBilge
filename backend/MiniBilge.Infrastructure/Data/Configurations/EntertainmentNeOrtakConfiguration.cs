using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class EntertainmentNeOrtakConfiguration
    : IEntityTypeConfiguration<EntertainmentNeOrtak>
{
    private static readonly JsonSerializerOptions _json =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public void Configure(EntityTypeBuilder<EntertainmentNeOrtak> builder)
    {
        builder.ToTable("entertainment_ne_ortak");
        builder.HasKey(n => n.Id);
        builder.Property(n => n.Id).UseIdentityColumn();

        builder.Property(n => n.Difficulty).IsRequired();
        builder.Property(n => n.Connection).IsRequired().HasMaxLength(300);
        builder.Property(n => n.CorrectAnswer).IsRequired().HasMaxLength(300);
        builder.Property(n => n.Explanation);
        builder.Property(n => n.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(n => n.IsActive).IsRequired().HasDefaultValue(true);
        builder.Property(n => n.CreatedAt).HasDefaultValueSql("now()");

        builder.Property(n => n.Clues)
               .HasColumnType("jsonb")
               .HasConversion(
                   v => JsonSerializer.Serialize(v, _json),
                   v => JsonSerializer.Deserialize<List<string>>(v, _json) ?? new List<string>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.Property(n => n.Options)
               .HasColumnType("jsonb")
               .HasConversion(
                   v => JsonSerializer.Serialize(v, _json),
                   v => JsonSerializer.Deserialize<List<string>>(v, _json) ?? new List<string>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.HasIndex(n => new { n.Difficulty, n.Language });
    }
}
