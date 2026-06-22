namespace MiniBilge.Application.Interfaces;

/// <summary>
/// Provider-agnostic TTS soyutlaması.
/// Google, Azure vb. implementasyonlar bu interface'i uygular.
/// </summary>
public interface ITtsProvider
{
    /// <summary>
    /// Verilen metni sentezler ve ham ses byte'larını (MP3) döner.
    /// </summary>
    /// <param name="text">Seslendirilecek metin</param>
    /// <param name="voiceKey">Soyut ses anahtarı: male_1 | male_2 | female_1 | female_2</param>
    Task<byte[]> SynthesizeAsync(string text, string voiceKey, CancellationToken ct = default);
}
