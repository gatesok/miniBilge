namespace MiniBilge.Application.Options;

public class TtsProviderOptions
{
    public const string SectionName = "TtsOptions";

    /// <summary>Aktif provider: "Google" | "Azure"</summary>
    public string ActiveProvider { get; set; } = "Google";

    /// <summary>
    /// Soyut VoiceKey → provider adına göre gerçek ses adı haritası.
    /// Örnek: VoiceKeys["male_1"]["Google"] = "en-US-Neural2-D"
    /// </summary>
    public Dictionary<string, Dictionary<string, string>> VoiceKeys { get; set; } = new();

    public TtsAudioStorageOptions AudioStorage { get; set; } = new();
}

public class TtsAudioStorageOptions
{
    /// <summary>"GoogleCloudStorage" | "AzureBlob"</summary>
    public string Provider { get; set; } = "GoogleCloudStorage";
    public string BucketName { get; set; } = string.Empty;

    /// <summary>Ses dosyalarının public base URL'i (trailing slash ile)</summary>
    public string BaseUrl { get; set; } = string.Empty;
}
