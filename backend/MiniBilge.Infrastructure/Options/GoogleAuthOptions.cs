namespace MiniBilge.Infrastructure.Options;

public class GoogleAuthOptions
{
    public const string SectionName = "GoogleAuth";

    public string ServerClientId { get; set; } = string.Empty;
}
