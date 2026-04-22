using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class MatchAnswerConfiguration : IEntityTypeConfiguration<MatchAnswer>
{
    public void Configure(EntityTypeBuilder<MatchAnswer> builder)
    {
        builder.ToTable("match_answers");
        
        builder.HasKey(ma => ma.Id);
        
        builder.Property(ma => ma.MatchSessionId)
            .IsRequired();
        
        builder.Property(ma => ma.ParticipantId)
            .IsRequired();
        
        builder.Property(ma => ma.QuestionId)
            .IsRequired();
        
        builder.Property(ma => ma.Answer)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.Property(ma => ma.IsCorrect)
            .IsRequired();
        
        builder.Property(ma => ma.AnsweredAt)
            .IsRequired();
        
        builder.Property(ma => ma.PointsEarned)
            .HasDefaultValue(0)
            .ValueGeneratedNever();
        
        builder.HasOne(ma => ma.Question)
            .WithMany()
            .HasForeignKey(ma => ma.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasIndex(ma => ma.MatchSessionId);
        builder.HasIndex(ma => ma.ParticipantId);
        builder.HasIndex(ma => new { ma.ParticipantId, ma.QuestionId })
            .IsUnique();
    }
}
