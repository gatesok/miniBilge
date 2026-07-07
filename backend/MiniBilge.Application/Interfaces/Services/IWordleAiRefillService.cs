namespace MiniBilge.Application.Interfaces.Services;

public interface IWordleAiRefillService
{
    /// <summary>
    /// Kullanılmamış kelime sayısı eşiğin altına düştüyse AI ile havuzu doldurur.
    /// </summary>
    Task RefillIfNeededAsync(string language = "tr", int threshold = 30);

    /// <summary>AI'dan yeni kelimeler üretip word_pool'a kaydeder.</summary>
    Task<int> RefillAsync(string language = "tr", int count = 20);
}
