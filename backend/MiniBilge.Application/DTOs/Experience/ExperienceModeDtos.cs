namespace MiniBilge.Application.DTOs.Experience;

public sealed class ExperienceModeDto
{
    public string Mode { get; init; } = string.Empty;
    public bool IsSelected { get; init; }
}

public sealed class UpdateExperienceModeRequest
{
    public string Mode { get; init; } = string.Empty;
}
