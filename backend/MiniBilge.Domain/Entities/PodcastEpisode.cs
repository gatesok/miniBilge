using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class PodcastEpisode : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public EnglishLevel EnglishLevel { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public ICollection<PodcastLine> Lines { get; set; } = new List<PodcastLine>();
    public ICollection<PodcastQuestion> Questions { get; set; } = new List<PodcastQuestion>();
}
