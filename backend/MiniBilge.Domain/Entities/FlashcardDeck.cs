using MiniBilge.Domain.Entities.Base;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Domain.Entities;

public class FlashcardDeck : BaseEntity
{
    public string Title { get; set; } = string.Empty;
    public EnglishLevel Level { get; set; }
    public Guid? EpisodeId { get; set; }
    public int DisplayOrder { get; set; }
    public bool IsActive { get; set; } = true;

    // Navigation
    public PodcastEpisode? Episode { get; set; }
    public ICollection<Flashcard> Cards { get; set; } = new List<Flashcard>();
}
