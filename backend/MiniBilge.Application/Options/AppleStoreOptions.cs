namespace MiniBilge.Application.Options;

public sealed class AppleStoreOptions
{
    public const string SectionName = "AppleStore";

    public string IssuerId { get; set; } = string.Empty;
    public string KeyId { get; set; } = string.Empty;
    public string BundleId { get; set; } = "com.minibilge.mobile";
    public string PrivateKey { get; set; } = string.Empty;
    public string MonthlyProductId { get; set; } = "minibilge_premium_monthly";
    public string YearlyProductId { get; set; } = "minibilge_premium_yearly";
}
