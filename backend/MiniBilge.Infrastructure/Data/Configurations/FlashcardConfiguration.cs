using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class FlashcardDeckConfiguration : IEntityTypeConfiguration<FlashcardDeck>
{
    public void Configure(EntityTypeBuilder<FlashcardDeck> builder)
    {
        builder.ToTable("flashcard_decks");
        builder.HasKey(d => d.Id);
        builder.Property(d => d.Title).IsRequired().HasMaxLength(200);
        builder.Property(d => d.Level).IsRequired();
        builder.Property(d => d.EpisodeId).IsRequired(false);
        builder.Property(d => d.DisplayOrder).IsRequired().HasDefaultValue(0);
        builder.Property(d => d.IsActive).IsRequired().HasDefaultValue(true);

        builder.HasIndex(d => d.Level);
        builder.HasIndex(d => d.EpisodeId);

        builder.HasOne(d => d.Episode)
               .WithMany()
               .HasForeignKey(d => d.EpisodeId)
               .IsRequired(false)
               .OnDelete(DeleteBehavior.SetNull);

        builder.HasMany(d => d.Cards)
               .WithOne(c => c.Deck)
               .HasForeignKey(c => c.DeckId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class FlashcardConfiguration : IEntityTypeConfiguration<Flashcard>
{
    public void Configure(EntityTypeBuilder<Flashcard> builder)
    {
        builder.ToTable("flashcards");
        builder.HasKey(c => c.Id);
        builder.Property(c => c.FrontText).IsRequired().HasMaxLength(500);
        builder.Property(c => c.BackText).IsRequired().HasMaxLength(500);
        builder.Property(c => c.ExampleSentence).IsRequired(false);
        builder.Property(c => c.AudioUrl).IsRequired(false);
        builder.Property(c => c.DisplayOrder).IsRequired().HasDefaultValue(0);
        builder.Property(c => c.IsActive).IsRequired().HasDefaultValue(true);

        builder.HasIndex(c => c.DeckId);

        builder.HasMany(c => c.Progresses)
               .WithOne(p => p.Flashcard)
               .HasForeignKey(p => p.FlashcardId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}

public class FlashcardProgressConfiguration : IEntityTypeConfiguration<FlashcardProgress>
{
    public void Configure(EntityTypeBuilder<FlashcardProgress> builder)
    {
        builder.ToTable("flashcard_progress");
        builder.HasKey(p => p.Id);
        builder.Property(p => p.IsLearned).IsRequired().HasDefaultValue(false);
        builder.Property(p => p.ReviewCount).IsRequired().HasDefaultValue(0);
        builder.Property(p => p.LastReviewedAt).IsRequired(false);

        // Her çocuk için her kart unique
        builder.HasIndex(p => new { p.ChildProfileId, p.FlashcardId }).IsUnique();

        builder.HasOne(p => p.ChildProfile)
               .WithMany()
               .HasForeignKey(p => p.ChildProfileId)
               .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(p => p.Flashcard)
               .WithMany(c => c.Progresses)
               .HasForeignKey(p => p.FlashcardId)
               .OnDelete(DeleteBehavior.Cascade);
    }
}
