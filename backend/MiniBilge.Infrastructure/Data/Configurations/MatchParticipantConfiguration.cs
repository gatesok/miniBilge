using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class MatchParticipantConfiguration : IEntityTypeConfiguration<MatchParticipant>
{
    public void Configure(EntityTypeBuilder<MatchParticipant> builder)
    {
        builder.ToTable("match_participants");
        
        builder.HasKey(mp => mp.Id);
        
        builder.Property(mp => mp.MatchSessionId)
            .IsRequired();
        
        builder.Property(mp => mp.ChildProfileId)
            .IsRequired();
        
        builder.Property(mp => mp.Score)
            .HasDefaultValue(0);
        
        builder.Property(mp => mp.JoinedAt)
            .IsRequired();
        
        builder.Property(mp => mp.IsReady)
            .HasDefaultValue(false);
        
        builder.HasOne(mp => mp.ChildProfile)
            .WithMany()
            .HasForeignKey(mp => mp.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(mp => mp.Answers)
            .WithOne(ma => ma.Participant)
            .HasForeignKey(ma => ma.ParticipantId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(mp => mp.MatchSessionId);
        builder.HasIndex(mp => mp.ChildProfileId);
    }
}
