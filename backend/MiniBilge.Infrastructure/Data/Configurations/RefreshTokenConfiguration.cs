using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class RefreshTokenConfiguration : IEntityTypeConfiguration<RefreshToken>
{
    public void Configure(EntityTypeBuilder<RefreshToken> builder)
    {
        builder.ToTable("refresh_tokens");
        
        builder.HasKey(r => r.Id);
        
        builder.Property(r => r.Token)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.HasIndex(r => r.Token)
            .IsUnique();
        
        builder.Property(r => r.ExpiresAt)
            .IsRequired();
        
        builder.Property(r => r.IsRevoked)
            .HasDefaultValue(false);
        
        builder.HasOne(r => r.User)
            .WithMany()
            .HasForeignKey(r => r.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
