using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class EntertainmentKimBuConfiguration
    : IEntityTypeConfiguration<EntertainmentKimBu>
{
    private static readonly JsonSerializerOptions _json =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public void Configure(EntityTypeBuilder<EntertainmentKimBu> builder)
    {
        builder.ToTable("entertainment_kim_bu");
        builder.HasKey(k => k.Id);
        builder.Property(k => k.Id).UseIdentityColumn();

        builder.Property(k => k.Difficulty).IsRequired();
        builder.Property(k => k.Subject).IsRequired().HasMaxLength(200);
        builder.Property(k => k.CorrectAnswer).IsRequired().HasMaxLength(200);
        builder.Property(k => k.Language).IsRequired().HasMaxLength(5).HasDefaultValue("tr");
        builder.Property(k => k.IsActive).IsRequired().HasDefaultValue(true);
        builder.Property(k => k.CreatedAt).HasDefaultValueSql("now()");

        builder.Property(k => k.Hints)
               .HasColumnType("jsonb")
               .HasConversion(
                   v => JsonSerializer.Serialize(v, _json),
                   v => JsonSerializer.Deserialize<List<string>>(v, _json) ?? new List<string>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.Property(k => k.Options)
               .HasColumnType("jsonb")
               .HasConversion(
                   v => JsonSerializer.Serialize(v, _json),
                   v => JsonSerializer.Deserialize<List<string>>(v, _json) ?? new List<string>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.HasIndex(k => new { k.Difficulty, k.Language });
    }
}
