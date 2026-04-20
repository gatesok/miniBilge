using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

public class Level : BaseEntity
{
    public Guid TopicId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public int Difficulty { get; set; } // 1-10 arası zorluk seviyesi
    public int DisplayOrder { get; set; }
    public int MinCorrectToPass { get; set; } = 7; // Geçmek için minimum doğru sayısı (10 sorudan)
    public bool IsActive { get; set; } = true;

    // Navigation properties
    public Topic Topic { get; set; } = null!;
    public ICollection<Question> Questions { get; set; } = new List<Question>();
}
