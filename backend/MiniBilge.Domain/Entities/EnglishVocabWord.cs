namespace MiniBilge.Domain.Entities;

/// <summary>
/// İngilizce kelime öğrenme oyununun kelime havuzu — english_vocab_word tablosu.
/// Tabloda soru değil kelime + anlam saklanır; çoktan seçmeli şıklar (çeldiriciler)
/// çalışma anında aynı CEFR seviyesi + aynı sözcük türünden dinamik üretilir.
/// </summary>
public class EnglishVocabWord
{
    public int     Id             { get; set; }
    public string  EnglishWord    { get; set; } = string.Empty;
    public string  TurkishMeaning { get; set; } = string.Empty;
    /// <summary>Sözcük türü (noun/verb/adjective/adverb...) — çeldirici filtresi; zorunlu.</summary>
    public string  PartOfSpeech   { get; set; } = string.Empty;
    /// <summary>CEFR seviyesi: A1/A2/B1/B2/C1/C2 — birincil eksen; zorunlu.</summary>
    public string  EnglishLevel   { get; set; } = string.Empty;
    /// <summary>
    /// Anlam grubu (ör. fruit/animal/color/family) — çeldiricilerin gerçekten kandırıcı
    /// (aynı temadan) olmasını sağlar. Opsiyonel; boşsa seviye+tür bazlı seçime düşülür.
    /// </summary>
    public string? SemanticGroup  { get; set; }
    /// <summary>Opsiyonel örnek cümle / ipucu.</summary>
    public string? ExampleSentence { get; set; }
    public bool    IsActive       { get; set; } = true;
    public DateTime CreatedAt     { get; set; }
}
