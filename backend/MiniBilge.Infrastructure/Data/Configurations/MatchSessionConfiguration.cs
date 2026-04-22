using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class MatchSessionConfiguration : IEntityTypeConfiguration<MatchSession>
{
    public void Configure(EntityTypeBuilder<MatchSession> builder)
    {
        builder.ToTable("match_sessions");
        
        builder.HasKey(ms => ms.Id);
        
        builder.Property(ms => ms.Status)
            .IsRequired()
            .HasConversion<int>();
        
        builder.HasMany(ms => ms.Participants)
            .WithOne(mp => mp.MatchSession)
            .HasForeignKey(mp => mp.MatchSessionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(ms => ms.Questions)
            .WithOne(mq => mq.MatchSession)
            .HasForeignKey(mq => mq.MatchSessionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasMany(ms => ms.Answers)
            .WithOne(ma => ma.MatchSession)
            .HasForeignKey(ma => ma.MatchSessionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(ms => ms.Status);
        builder.HasIndex(ms => ms.CreatedAt);
    }
}
