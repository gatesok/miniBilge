namespace MiniBilge.Application.DTOs.RolePlay;

// ─── Scenario ─────────────────────────────────────────────────────────────────

public class ScenarioDto
{
    public string Key { get; set; } = string.Empty;
    public string Title { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
    public string CharacterName { get; set; } = string.Empty;
    public string CharacterRole { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
}

// ─── Session Start ─────────────────────────────────────────────────────────────

public class StartRolePlayRequest
{
    public Guid ChildProfileId { get; set; }
    public string ScenarioKey { get; set; } = string.Empty;
    public string Level { get; set; } = string.Empty;
}

public class StartRolePlayResponse
{
    public Guid SessionId { get; set; }
    public string AssistantMessage { get; set; } = string.Empty;
    public string CharacterName { get; set; } = string.Empty;
    public string CharacterRole { get; set; } = string.Empty;
    public string ScenarioTitle { get; set; } = string.Empty;
    public string Emoji { get; set; } = string.Empty;
}

// ─── Turn ──────────────────────────────────────────────────────────────────────

public class SendTurnRequest
{
    public Guid SessionId { get; set; }
    public string UserMessage { get; set; } = string.Empty;
}

public class SendTurnResponse
{
    public string AssistantMessage { get; set; } = string.Empty;
    public string? GrammarNote { get; set; }
    public int TurnCount { get; set; }
    public bool MaxTurnsReached { get; set; }
}

// ─── End Session ───────────────────────────────────────────────────────────────

public class EndSessionRequest
{
    public Guid SessionId { get; set; }
    public Guid? ChildProfileId { get; set; }
}

public class EndSessionResponse
{
    public int Score { get; set; }
    public string Feedback { get; set; } = string.Empty;
    public int TurnCount { get; set; }
    public int CoinsEarned { get; set; }
    public int StarsEarned { get; set; }
}
