namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateFactOrFictionRequest
{
    /// <summary>"Kolay" | "Orta" | "Zor"</summary>
    public string Difficulty { get; set; } = "Orta";

    /// <summary>Daha önce gösterilen ifadeler — tekrar önlemek için (max 15).</summary>
    public List<string> ForbiddenStatements { get; set; } = [];

    /// <summary>Tarih seed (her gün farklı set için).</summary>
    public string? DateSeed { get; set; }
}

public class FactOrFictionQuestionDto
{
    /// <summary>Kullanıcıya gösterilen ifade.</summary>
    public string Statement   { get; set; } = string.Empty;

    /// <summary>true = gerçek, false = uydurma.</summary>
    public bool   IsReal      { get; set; }

    /// <summary>Cevap sonrası gösterilen kısa açıklama.</summary>
    public string Explanation { get; set; } = string.Empty;
}
