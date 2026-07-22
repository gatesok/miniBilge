using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class MatchRequestConfiguration : IEntityTypeConfiguration<MatchRequest>
{
    public void Configure(EntityTypeBuilder<MatchRequest> builder)
    {
        builder.ToTable("match_requests");
        
        builder.HasKey(mr => mr.Id);
        
        builder.Property(mr => mr.ChildProfileId)
            .IsRequired();
        
        builder.Property(mr => mr.RequestedAt)
            .IsRequired();
        
        builder.Property(mr => mr.Status)
            .IsRequired()
            .HasConversion<int>();

        builder.Property(mr => mr.CompetitionType).HasConversion<int?>();
        builder.Property(mr => mr.CompetitionTopicKey).HasMaxLength(200);
        builder.Property(mr => mr.CompetitionDifficulty).HasMaxLength(20);
        
        builder.HasOne(mr => mr.ChildProfile)
            .WithMany()
            .HasForeignKey(mr => mr.ChildProfileId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(mr => mr.MatchSession)
            .WithMany()
            .HasForeignKey(mr => mr.MatchSessionId)
            .OnDelete(DeleteBehavior.SetNull);
        
        builder.HasIndex(mr => mr.ChildProfileId);
        builder.HasIndex(mr => mr.Status);
        builder.HasIndex(mr => mr.RequestedAt);
    }
}
