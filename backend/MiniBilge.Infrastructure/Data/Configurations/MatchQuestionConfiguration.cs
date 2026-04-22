using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class MatchQuestionConfiguration : IEntityTypeConfiguration<MatchQuestion>
{
    public void Configure(EntityTypeBuilder<MatchQuestion> builder)
    {
        builder.ToTable("match_questions");
        
        builder.HasKey(mq => mq.Id);
        
        builder.Property(mq => mq.MatchSessionId)
            .IsRequired();
        
        builder.Property(mq => mq.QuestionId)
            .IsRequired();
        
        builder.Property(mq => mq.QuestionOrder)
            .IsRequired();
        
        builder.HasOne(mq => mq.Question)
            .WithMany()
            .HasForeignKey(mq => mq.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(mq => mq.MatchSessionId);
        builder.HasIndex(mq => new { mq.MatchSessionId, mq.QuestionOrder })
            .IsUnique();
    }
}
