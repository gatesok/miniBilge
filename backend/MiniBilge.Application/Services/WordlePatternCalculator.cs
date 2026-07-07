namespace MiniBilge.Application.Services;

/// <summary>
/// Wordle harf pattern hesaplama algoritması.
/// Türkçe karakterler (Ç, Ğ, İ, Ö, Ş, Ü) dahil doğru çalışır.
/// Çift harf kuralı standart Wordle mantığıyla uygulanır.
/// </summary>
public static class WordlePatternCalculator
{
    public const string Correct = "correct";  // 🟩 Doğru harf, doğru pozisyon
    public const string Present = "present";  // 🟨 Harf var ama yanlış pozisyon
    public const string Absent  = "absent";   // ⬛ Harf kelimede yok

    /// <summary>
    /// Tahmini cevapla karşılaştırır ve her harf için pattern döner.
    /// </summary>
    /// <param name="answer">Doğru cevap (büyük harf, 5 karakter)</param>
    /// <param name="guess">Kullanıcı tahmini (büyük harf, 5 karakter)</param>
    /// <returns>"correct" | "present" | "absent" dizisi</returns>
    public static string[] Calculate(string answer, string guess)
    {
        var length  = answer.Length;
        var result  = new string[length];
        var answerUsed = new bool[length];
        var guessUsed  = new bool[length];

        // Geçiş 1: Tam eşleşmeler (correct) — önce bunları işaret et
        for (var i = 0; i < length; i++)
        {
            if (guess[i] == answer[i])
            {
                result[i]     = Correct;
                answerUsed[i] = true;
                guessUsed[i]  = true;
            }
        }

        // Geçiş 2: Mevcut ama yanlış pozisyon (present) veya yok (absent)
        for (var i = 0; i < length; i++)
        {
            if (guessUsed[i]) continue;  // Zaten correct olarak işaretlendi

            var found = false;
            for (var j = 0; j < length; j++)
            {
                if (!answerUsed[j] && guess[i] == answer[j])
                {
                    result[i]     = Present;
                    answerUsed[j] = true;
                    found         = true;
                    break;
                }
            }

            if (!found) result[i] = Absent;
        }

        return result;
    }

    /// <summary>
    /// Tahminin doğru olup olmadığını kontrol eder (tüm harfler correct).
    /// </summary>
    public static bool IsCorrect(string[] pattern)
        => pattern.All(p => p == Correct);

    /// <summary>
    /// Pattern'i emoji string'e dönüştürür (paylaşım kartı için).
    /// </summary>
    public static string ToEmojiString(string[] pattern)
        => string.Concat(pattern.Select(p => p switch
        {
            Correct => "🟩",
            Present => "🟨",
            _       => "⬛",
        }));
}
