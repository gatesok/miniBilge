namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateNeOrtakRequest
{
    /// <summary>"Kolay" | "Orta" | "Zor"</summary>
    public string Difficulty { get; set; } = "Orta";

    /// <summary>Daha önce gösterilen bağlantılar — tekrar önlemek için (max 40).</summary>
    public List<string> ForbiddenConnections { get; set; } = [];

    /// <summary>Tarih seed (günde farklı set için).</summary>
    public string? DateSeed { get; set; }
}

public class NeOrtakQuestionDto
{
    /// <summary>4 görünüşte alakasız ipucu.</summary>
    public List<string> Clues { get; set; } = [];

    /// <summary>Gizli ortak bağlantı (doğru cevap).</summary>
    public string Connection { get; set; } = string.Empty;

    /// <summary>4 çoktan seçmeli şık — doğru cevap dahil.</summary>
    public List<string> Options { get; set; } = [];

    /// <summary>Doğru cevap (Options listesinden biri).</summary>
    public string CorrectAnswer { get; set; } = string.Empty;

    /// <summary>Cevap sonrası gösterilen açıklama.</summary>
    public string Explanation { get; set; } = string.Empty;
}
