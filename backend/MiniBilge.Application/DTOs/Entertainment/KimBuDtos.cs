namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateKimBuRequest
{
    public string Difficulty { get; set; } = "Orta";
    public List<int> ExcludeIds { get; set; } = [];
    public List<string> ForbiddenSubjects { get; set; } = [];
    public string? DateSeed { get; set; }
}

public class KimBuSubjectDto
{
    public int          Id            { get; set; }
    public string       Subject       { get; set; } = string.Empty;
    public List<string> Hints         { get; set; } = [];
    public List<string> Options       { get; set; } = [];
    public string       CorrectAnswer { get; set; } = string.Empty;
}

public class KimBuRoundDto
{
    public List<KimBuSubjectDto> Subjects { get; set; } = [];
}
