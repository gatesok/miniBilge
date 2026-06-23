using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class PodcastQuestion : BaseEntity
{
    public Guid EpisodeId { get; set; }
    public string QuestionText { get; set; } = string.Empty;
    public PodcastQuestionType QuestionType { get; set; }
    public string CorrectAnswer { get; set; } = string.Empty;
    public string? Explanation { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public PodcastEpisode Episode { get; set; } = null!;
    public ICollection<PodcastQuestionOption> Options { get; set; } = new List<PodcastQuestionOption>();
}
