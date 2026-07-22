namespace MiniBilge.Application.Options;

public class OpenAiSettings
{
    public const string SectionName = "OpenAI";

    public string ApiKey { get; set; } = string.Empty;

    /// <summary>Varsayılan model: "gpt-4o-mini"</summary>
    public string Model { get; set; } = "gpt-4o-mini";

    /// <summary>Deploy ortamında güncel model fiyatına göre verilmelidir.</summary>
    public decimal? InputCostPerMillionTokensUsd { get; set; }

    /// <summary>Deploy ortamında güncel model fiyatına göre verilmelidir.</summary>
    public decimal? OutputCostPerMillionTokensUsd { get; set; }

    public int TimeoutSeconds { get; set; } = 45;
}
