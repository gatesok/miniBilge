using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using MiniBilge.Domain.Entities;

namespace MiniBilge.Infrastructure.Data.Configurations;

public class AnswerAttemptConfiguration : IEntityTypeConfiguration<AnswerAttempt>
{
    public void Configure(EntityTypeBuilder<AnswerAttempt> builder)
    {
        builder.ToTable("answer_attempts");
        
        builder.HasKey(aa => aa.Id);
        
        builder.Property(aa => aa.SubmittedAnswer)
            .IsRequired()
            .HasMaxLength(500);
        
        builder.Property(aa => aa.IsCorrect)
            .IsRequired();
        
        builder.Property(aa => aa.TimeTakenSeconds)
            .IsRequired(false);
        
        builder.Property(aa => aa.AttemptedAt)
            .IsRequired();
        
        // Relationships
        builder.HasOne(aa => aa.Child)
            .WithMany()
            .HasForeignKey(aa => aa.ChildId)
            .OnDelete(DeleteBehavior.Cascade);
        
        builder.HasOne(aa => aa.Question)
            .WithMany()
            .HasForeignKey(aa => aa.QuestionId)
            .OnDelete(DeleteBehavior.Cascade);
        
        // Indexes
        builder.HasIndex(aa => aa.ChildId);
        builder.HasIndex(aa => aa.QuestionId);
        builder.HasIndex(aa => aa.AttemptedAt);
    }
}
