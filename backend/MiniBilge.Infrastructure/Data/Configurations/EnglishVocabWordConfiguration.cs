using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class EnglishVocabWordConfiguration : IEntityTypeConfiguration<EnglishVocabWord>
{
    public void Configure(EntityTypeBuilder<EnglishVocabWord> builder)
    {
        builder.ToTable("english_vocab_word");
        builder.HasKey(w => w.Id);
        builder.Property(w => w.Id).UseIdentityColumn();

        builder.Property(w => w.EnglishWord).IsRequired().HasMaxLength(80);
        builder.Property(w => w.TurkishMeaning).IsRequired().HasMaxLength(160);
        builder.Property(w => w.PartOfSpeech).IsRequired().HasMaxLength(20);
        builder.Property(w => w.EnglishLevel).IsRequired().HasMaxLength(2);
        builder.Property(w => w.SemanticGroup).HasMaxLength(40);
        builder.Property(w => w.ExampleSentence).HasMaxLength(300);
        builder.Property(w => w.IsActive).IsRequired().HasDefaultValue(true);
        builder.Property(w => w.CreatedAt).HasDefaultValueSql("now()");

        // Aynı kelime + anlam iki kez girilmesin.
        builder.HasIndex(w => new { w.EnglishWord, w.TurkishMeaning }).IsUnique();

        // Birincil seçim + çeldirici filtresi için birleşik index.
        builder.HasIndex(w => new { w.EnglishLevel, w.PartOfSpeech, w.IsActive });

        // Anlam grubu bazlı (gerçekten kandırıcı) çeldirici seçimi için index.
        builder.HasIndex(w => new { w.EnglishLevel, w.SemanticGroup, w.IsActive });
    }
}
