using MiniBilge.Application.DTOs.Education;

namespace MiniBilge.Application.DTOs.Match;

public class MatchSessionDto
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime? StartedAt { get; set; }
    public DateTime? EndedAt { get; set; }
    public string Status { get; set; } = string.Empty;
    public MatchParticipantDto Player1 { get; set; } = null!;
    public MatchParticipantDto Player2 { get; set; } = null!;
    public MatchParticipantDto? Winner { get; set; }
    public List<QuestionDto> Questions { get; set; } = new();
}

public class MatchParticipantDto
{
    public Guid ChildId { get; set; }
    public string Name { get; set; } = string.Empty;
    public int Score { get; set; }
    public string? AvatarImageUrl { get; set; }
}

public class MatchStatsDto
{
    public int TotalMatches { get; set; }
    public int Wins { get; set; }
    public int Losses { get; set; }
    public double WinRate { get; set; }
}
