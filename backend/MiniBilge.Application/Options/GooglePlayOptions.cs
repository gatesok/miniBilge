namespace MiniBilge.Application.Options;

public sealed class GooglePlayOptions
{
    public const string SectionName = "GooglePlay";

    public string PackageName { get; set; } = "com.minibilge.mobile";
    public string MonthlyProductId { get; set; } = "minibilge_premium_monthly";
    public string YearlyProductId { get; set; } = "minibilge_premium_yearly";

    // Pub/Sub push isteklerini doğrulamak için paylaşılan gizli token (URL'de ?token=).
    // Boşsa webhook fail-closed çalışır (istekler reddedilir).
    public string PushToken { get; set; } = string.Empty;
}
