using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class UserExternalLoginConfiguration : IEntityTypeConfiguration<UserExternalLogin>
{
    public void Configure(EntityTypeBuilder<UserExternalLogin> builder)
    {
        builder.ToTable("user_external_logins");

        builder.HasKey(login => login.Id);

        builder.Property(login => login.Provider)
            .IsRequired()
            .HasConversion<int>();

        builder.Property(login => login.ProviderSubject)
            .IsRequired()
            .HasMaxLength(255);

        builder.Property(login => login.ProviderEmail)
            .HasMaxLength(255);

        builder.HasIndex(login => new { login.Provider, login.ProviderSubject })
            .IsUnique();

        builder.HasIndex(login => new { login.UserId, login.Provider })
            .IsUnique();

        builder.HasOne(login => login.User)
            .WithMany(user => user.ExternalLogins)
            .HasForeignKey(login => login.UserId)
            .OnDelete(DeleteBehavior.Cascade);
    }
}
