using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.ToTable("users");
        
        builder.HasKey(u => u.Id);
        
        builder.Property(u => u.Email)
            .IsRequired()
            .HasMaxLength(255);
        
        builder.HasIndex(u => u.Email)
            .IsUnique();
        
        builder.Property(u => u.PasswordHash)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.Property(u => u.Role)
            .IsRequired()
            .HasConversion<int>();
        
        builder.Property(u => u.IsEmailConfirmed)
            .HasDefaultValue(false);

        builder.Property(u => u.CanUseOnlineSpeech)
            .HasColumnName("CanUseOnlineSpeech")
            .HasDefaultValue(true);
        
        builder.HasOne(u => u.ParentProfile)
            .WithOne(p => p.User)
            .HasForeignKey<ParentProfile>(p => p.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
