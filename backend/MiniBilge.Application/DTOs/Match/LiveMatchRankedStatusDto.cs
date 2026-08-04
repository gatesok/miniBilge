namespace MiniBilge.Application.DTOs.Match;

/// <summary>
/// Bir çocuğun canlı yarışta sıralama puanı (TotalScore) üretme durumunu döner.
/// Sıralama anti-abuse kuralı: günün ilk 5 tamamlanan yarışı + aynı rakiple en fazla 2 maç.
/// </summary>
public class LiveMatchRankedStatusDto
{
    /// <summary>Bugün sıralamaya sayan kalan yarış hakkı (0..DailyRankedLimit).</summary>
    public int RankedRemainingToday { get; set; }

    /// <summary>Günlük sıralama-sayan yarış üst sınırı.</summary>
    public int DailyRankedLimit { get; set; }

    /// <summary>Sıradaki yarışın sıralama puanı üretip üretmeyeceği.</summary>
    public bool NextGameRanked { get; set; }

    /// <summary>
    /// Rakip biliniyorsa (davet), bu rakiple bugün hâlâ sıralama-sayan maç yapılabilir mi.
    /// Rastgele kuyrukta rakip bilinmediği için null döner.
    /// </summary>
    public bool? VsOpponentEligible { get; set; }
}
