using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class UserSubscriptionConfiguration : IEntityTypeConfiguration<UserSubscription>
{
    public void Configure(EntityTypeBuilder<UserSubscription> builder)
    {
        builder.ToTable("user_subscriptions");
        builder.HasKey(x => x.Id);
        builder.Property(x => x.Provider).HasConversion<int>().IsRequired();
        builder.Property(x => x.Status).HasConversion<int>().IsRequired();
        builder.Property(x => x.ProductId).HasMaxLength(150).IsRequired();
        builder.Property(x => x.OriginalTransactionId).HasMaxLength(255).IsRequired();
        builder.Property(x => x.Environment).HasMaxLength(30).IsRequired();
        builder.HasIndex(x => new { x.Provider, x.OriginalTransactionId }).IsUnique();
        builder.HasIndex(x => new { x.UserId, x.Status, x.ExpiresAt });
        builder.HasOne(x => x.User)
            .WithMany(x => x.Subscriptions)
            .HasForeignKey(x => x.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
