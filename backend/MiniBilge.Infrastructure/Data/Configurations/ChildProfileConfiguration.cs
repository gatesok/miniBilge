using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class ChildProfileConfiguration : IEntityTypeConfiguration<ChildProfile>
{
    public void Configure(EntityTypeBuilder<ChildProfile> builder)
    {
        builder.ToTable("child_profiles");
        
        builder.HasKey(c => c.Id);
        
        builder.Property(c => c.Name)
            .IsRequired()
            .HasMaxLength(100);
        
        builder.Property(c => c.DateOfBirth)
            .IsRequired();
        
        builder.Property(c => c.GradeLevel)
            .IsRequired()
            .HasConversion<int>();
        
        builder.Property(c => c.AvatarImageUrl)
            .HasMaxLength(500);
        
        builder.Property(c => c.TotalCoins)
            .HasDefaultValue(0);
        
        builder.Property(c => c.TotalStars)
            .HasDefaultValue(0);

        builder.Property(c => c.AdultCompetitionPoints)
            .HasDefaultValue(0);

        builder.Property(c => c.AdultCompetitionWins)
            .HasDefaultValue(0);

        builder.Property(c => c.AdultCompetitionGamesPlayed)
            .HasDefaultValue(0);

        builder.Property(c => c.PodcastListeningMode)
            .IsRequired()
            .HasConversion<int>()
            .HasDefaultValue(PodcastListeningMode.Offline);
    }
}
