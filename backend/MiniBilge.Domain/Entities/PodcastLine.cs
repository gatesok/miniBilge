using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class PodcastLine : BaseEntity
{
    public Guid EpisodeId { get; set; }
    public string SpeakerName { get; set; } = string.Empty;
    public SpeakerGender SpeakerGender { get; set; }
    public string Text { get; set; } = string.Empty;
    public string? TranslationTr { get; set; }
    public int DisplayOrder { get; set; }

    // Navigation
    public PodcastEpisode Episode { get; set; } = null!;
}
