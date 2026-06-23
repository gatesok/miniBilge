using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class PodcastQuestionOption : BaseEntity
{
    public Guid PodcastQuestionId { get; set; }
    public string OptionText { get; set; } = string.Empty;
    public int DisplayOrder { get; set; } // 0=A, 1=B, 2=C, 3=D

    // Navigation
    public PodcastQuestion Question { get; set; } = null!;
}
