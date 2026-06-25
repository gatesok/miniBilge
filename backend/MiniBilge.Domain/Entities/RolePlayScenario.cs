namespace MiniBilge.Domain.Entities;

public class RolePlayScenario
{
    public Guid Id { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public string CharacterName { get; set; } = string.Empty;
    public string CharacterRole { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
    public string OpeningLine { get; set; } = string.Empty;
    public string SystemPrompt { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public int DisplayOrder { get; set; } = 0;
    public DateTime CreatedAt { get; set; }
}
