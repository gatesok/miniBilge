namespace MiniBilge.Application.DTOs.Entertainment;

public class GenerateKimBuRequest
{
    /// <summary>"Kolay" | "Orta" | "Zor"</summary>
    public string Difficulty { get; set; } = "Orta";

    /// <summary>Daha önce gösterilen konu adları — tekrar önlemek için (max 20).</summary>
    public List<string> ForbiddenSubjects { get; set; } = [];

    /// <summary>Tarih seed (günde farklı set için).</summary>
    public string? DateSeed { get; set; }
}

public class KimBuSubjectDto
{
    /// <summary>Konu adı (kişi, film, marka vs.) — cevap.</summary>
    public string Subject { get; set; } = string.Empty;

    /// <summary>5 ipucu, muğlaktan açığa doğru sıralı.</summary>
    public List<string> Hints { get; set; } = [];

    /// <summary>4 çoktan seçmeli şık — doğru cevap dahil.</summary>
    public List<string> Options { get; set; } = [];

    /// <summary>Doğru cevap (Options listesinden biri).</summary>
    public string CorrectAnswer { get; set; } = string.Empty;
}

public class KimBuRoundDto
{
    /// <summary>5 konu — her biri bağımsız bir "Kim Bu?" turu.</summary>
    public List<KimBuSubjectDto> Subjects { get; set; } = [];
}
