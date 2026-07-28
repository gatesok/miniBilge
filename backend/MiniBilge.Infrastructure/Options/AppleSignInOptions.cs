namespace MiniBilge.Infrastructure.Options;

public class AppleSignInOptions
{
    public const string SectionName = "AppleSignIn";

    public string ClientId { get; set; } = string.Empty;
    public string TeamId { get; set; } = string.Empty;
    public string KeyId { get; set; } = string.Empty;
    public string PrivateKey { get; set; } = string.Empty;
}
