using MiniBilge.Application.DTOs.Pronunciation;

namespace MiniBilge.Application.Interfaces;

public interface IPronunciationService
{
    /// <summary>
    /// Hedef cümle ile speech_to_text çıktısını kelime kelime karşılaştırır.
    /// Yanlış kelimelere GPT-4o-mini ile Türkçe telaffuz ipucu üretir.
    /// </summary>
    Task<PronunciationResultDto> EvaluatePronunciationAsync(EvaluatePronunciationRequest request);

    /// <summary>
    /// Verilen CEFR seviyesine ait flashcard örnek cümleleri döndürür.
    /// Sonuç yoksa seviyeye göre fallback cümleler kullanılır.
    /// </summary>
    Task<List<string>> GetSentencesAsync(int level, int count = 10);
}
