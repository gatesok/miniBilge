namespace MiniBilge.Application.Options;

public sealed class ChildProfileOptions
{
    public const string SectionName = "ChildProfile";

    // Deploy güvenliği: default false → mevcut canlı mobil sürüm etkilenmez.
    // Yeni sürüm yayınlanınca true'ya çekilerek gerçek server-side limit devreye alınır.
    public bool EnforceLimit { get; set; } = false;

    // Premium olmayan ebeveyn için maksimum aktif çocuk profili sayısı.
    public int FreeLimit { get; set; } = 1;

    // Premium ebeveyn için maksimum aktif çocuk profili sayısı.
    public int PremiumLimit { get; set; } = 3;
}
