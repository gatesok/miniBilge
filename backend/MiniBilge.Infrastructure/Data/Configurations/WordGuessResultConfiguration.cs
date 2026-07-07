using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class WordGuessResultConfiguration : IEntityTypeConfiguration<WordGuessResult>
{
    private static readonly JsonSerializerOptions _jsonOpts =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public void Configure(EntityTypeBuilder<WordGuessResult> builder)
    {
        builder.ToTable("word_guess_result");
        builder.HasKey(r => r.Id);

        builder.Property(r => r.Date).IsRequired();
        builder.Property(r => r.Solved).IsRequired().HasDefaultValue(false);
        builder.Property(r => r.AttemptsUsed).IsRequired().HasDefaultValue(0);
        builder.Property(r => r.CompletedAt);
        builder.Property(r => r.CreatedAt).IsRequired();

        // JSONB sütunu — List<WordleGuess> → JSON serialize/deserialize
        builder.Property(r => r.Guesses)
               .HasColumnType("jsonb")
               .HasConversion(
                   v  => JsonSerializer.Serialize(v, _jsonOpts),
                   v  => JsonSerializer.Deserialize<List<WordleGuess>>(v, _jsonOpts) ?? new List<WordleGuess>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.HasOne(r => r.ChildProfile)
               .WithMany()
               .HasForeignKey(r => r.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(r => r.WordPool)
               .WithMany()
               .HasForeignKey(r => r.WordPoolId)
               .OnDelete(DeleteBehavior.Restrict);

        builder.HasIndex(r => new { r.ChildProfileId, r.Date }).IsUnique();
        builder.HasIndex(r => r.Date);

        builder.Ignore(r => r.IsDeleted);
        builder.Ignore(r => r.UpdatedAt);
    }
}
