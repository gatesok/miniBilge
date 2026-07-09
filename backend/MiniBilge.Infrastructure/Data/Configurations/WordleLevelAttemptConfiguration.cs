using System.Text.Json;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class WordleLevelAttemptConfiguration : IEntityTypeConfiguration<WordleLevelAttempt>
{
    private static readonly JsonSerializerOptions _json =
        new() { PropertyNamingPolicy = JsonNamingPolicy.CamelCase };

    public void Configure(EntityTypeBuilder<WordleLevelAttempt> builder)
    {
        builder.ToTable("wordle_level_attempt");
        builder.HasKey(a => a.Id);

        builder.Property(a => a.Level).IsRequired();
        builder.Property(a => a.Word).IsRequired().HasMaxLength(10);
        builder.Property(a => a.Hint).HasMaxLength(200);
        builder.Property(a => a.WordLength).IsRequired();
        builder.Property(a => a.Solved).IsRequired().HasDefaultValue(false);
        builder.Property(a => a.Finished).IsRequired().HasDefaultValue(false);
        builder.Property(a => a.AttemptsUsed).IsRequired().HasDefaultValue(0);
        builder.Property(a => a.StarsEarned).IsRequired().HasDefaultValue(0);
        builder.Property(a => a.Skipped).IsRequired().HasDefaultValue(false);
        builder.Property(a => a.CompletedAt);
        builder.Property(a => a.CreatedAt).IsRequired();

        // JSONB sütunu
        builder.Property(a => a.Guesses)
               .HasColumnType("jsonb")
               .HasConversion(
                   v => JsonSerializer.Serialize(v, _json),
                   v => JsonSerializer.Deserialize<List<WordleGuess>>(v, _json) ?? new List<WordleGuess>())
               .HasDefaultValueSql("'[]'::jsonb");

        builder.HasOne(a => a.ChildProfile)
               .WithMany()
               .HasForeignKey(a => a.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasIndex(a => new { a.ChildProfileId, a.Level }).IsUnique();
        builder.HasIndex(a => new { a.ChildProfileId, a.Word }).IsUnique();
        builder.HasIndex(a => new { a.ChildProfileId, a.WordLength });

        builder.Ignore(a => a.IsDeleted);
        builder.Ignore(a => a.UpdatedAt);
    }
}
