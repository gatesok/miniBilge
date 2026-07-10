namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateNeOrtakRequest
{
    public string Difficulty { get; set; } = "Orta";
    public List<int> ExcludeIds { get; set; } = [];
    public List<string> ForbiddenConnections { get; set; } = [];
    public string? DateSeed { get; set; }
}

public class NeOrtakQuestionDto
{
    public int         Id            { get; set; }
    public List<string> Clues        { get; set; } = [];
    public string       Connection   { get; set; } = string.Empty;
    public List<string> Options      { get; set; } = [];
    public string       CorrectAnswer{ get; set; } = string.Empty;
    public string       Explanation  { get; set; } = string.Empty;
}
