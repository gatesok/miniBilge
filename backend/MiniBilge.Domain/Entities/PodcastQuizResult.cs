using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class PodcastQuizResult : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public Guid EpisodeId { get; set; }
    public int CorrectCount { get; set; }
    public int TotalQuestions { get; set; }
    public int StarsEarned { get; set; }
    public int CoinsEarned { get; set; }
    public DateTime CompletedAt { get; set; }

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;
    public PodcastEpisode Episode { get; set; } = null!;
}
