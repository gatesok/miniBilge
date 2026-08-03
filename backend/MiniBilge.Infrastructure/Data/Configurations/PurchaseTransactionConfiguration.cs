using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class PurchaseTransactionConfiguration : IEntityTypeConfiguration<PurchaseTransaction>
{
    public void Configure(EntityTypeBuilder<PurchaseTransaction> builder)
    {
        builder.ToTable("purchase_transactions");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Provider).HasConversion<int>().IsRequired();
        builder.Property(x => x.DedupKey).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Source).HasMaxLength(40).IsRequired();
        builder.Property(x => x.NotificationType).HasMaxLength(100);
        builder.Property(x => x.OriginalTransactionId).HasMaxLength(255);
        builder.Property(x => x.TransactionId).HasMaxLength(255);
        builder.Property(x => x.ProductId).HasMaxLength(150);
        builder.Property(x => x.Environment).HasMaxLength(30);
        builder.Property(x => x.Status).HasConversion<int>();

        builder.HasIndex(x => new { x.Provider, x.DedupKey }).IsUnique();
        builder.HasIndex(x => x.OriginalTransactionId);

        builder.HasOne(x => x.User)
            .WithMany()
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.SetNull);
    }
}
