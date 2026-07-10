namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateFactOrFictionRequest
{
    /// <summary>"Kolay" | "Orta" | "Zor"</summary>
    public string Difficulty { get; set; } = "Orta";
    /// <summary>DB-first: daha önce gösterilen ID'ler.</summary>
    public List<int> ExcludeIds { get; set; } = [];
    /// <summary>GPT fallback için yasaklı ifadeler.</summary>
    public List<string> ForbiddenStatements { get; set; } = [];
    public string? DateSeed { get; set; }
}

public class FactOrFictionQuestionDto
{
    public int    Id          { get; set; }
    public string Statement   { get; set; } = string.Empty;
    public bool   IsReal      { get; set; }
    public string Explanation { get; set; } = string.Empty;
}
