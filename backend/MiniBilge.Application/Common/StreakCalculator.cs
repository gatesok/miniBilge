namespace MiniBilge.Application.Common;

/// <summary>
/// Günlük öğrenme serisini (streak) deterministik biçimde hesaplar.
/// Cihazdan bağımsız, backend'de profil bazında kullanılmak üzere saf fonksiyondur.
/// </summary>
public static class StreakCalculator
{
    /// <summary>
    /// Bir aktivite gerçekleştiğinde yeni seri değerini döndürür.
    /// Aynı gün tekrar aktivite seriyi artırmaz; bir (veya daha fazla) gün
    /// atlanırsa seri 1'e döner; dün aktivite varsa seri bir artar.
    /// </summary>
    public static int Next(int currentStreak, DateOnly? lastActivity, DateOnly today)
    {
        if (lastActivity is null) return 1;
        if (lastActivity.Value == today) return currentStreak < 1 ? 1 : currentStreak;
        if (lastActivity.Value == today.AddDays(-1)) return currentStreak + 1;
        return 1; // gün atlandı (veya ileri tarih) → seri sıfırlanır
    }
}
