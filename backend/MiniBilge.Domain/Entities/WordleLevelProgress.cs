using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>Kullanıcının Kelime Oyunu seviye ilerlemesini tutar.</summary>
public class WordleLevelProgress : BaseEntity
{
    public Guid ChildProfileId { get; set; }
    public int  CurrentLevel   { get; set; } = 1;
    public int  HighestLevel   { get; set; } = 1;
    public int  TotalSolved    { get; set; } = 0;
    public int  CurrentStreak  { get; set; } = 0;
    public int  BestStreak     { get; set; } = 0;
    public int  SkipTickets    { get; set; } = 0;

    // Navigation
    public ChildProfile ChildProfile { get; set; } = null!;

    // ── Seviye hesaplama yardımcıları ──────────────────────────────────────────

    /// <summary>Verilen seviyenin kelime uzunluğunu döner.</summary>
    public static int WordLengthForLevel(int level) => level switch
    {
        <= 10  => 4,
        <= 50  => 5,
        <= 150 => 6,
        _      => 7,
    };

    /// <summary>Verilen seviyenin zorluk etiketini döner (GPT prompt için).</summary>
    public static string DifficultyForLevel(int level) => level switch
    {
        <= 10  => "Kolay",
        <= 25  => "Kolay-Orta",
        <= 50  => "Orta",
        <= 100 => "Orta-Zor",
        <= 150 => "Zor",
        _      => "Uzman",
    };

    /// <summary>Verilen seviyenin maksimum tahmin hakkını döner.</summary>
    public static int MaxAttemptsForLevel(int level) => level switch
    {
        <= 10  => 7,
        <= 150 => 6,
        _      => 5,
    };
}
