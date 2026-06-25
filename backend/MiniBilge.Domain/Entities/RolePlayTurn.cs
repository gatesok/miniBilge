namespace MiniBilge.Domain.Entities;

public class RolePlayTurn
{
    public Guid Id { get; set; }
    public Guid SessionId { get; set; }
    public string Role { get; set; } = string.Empty;    // "user" | "assistant"
    public string Content { get; set; } = string.Empty;
    public string? GrammarNote { get; set; }             // Sadece assistant turlarında
    public DateTime CreatedAt { get; set; }

    // Navigation
    public RolePlaySession Session { get; set; } = null!;
}
