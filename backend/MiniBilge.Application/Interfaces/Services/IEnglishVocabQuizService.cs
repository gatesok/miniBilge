using MiniBilge.Application.DTOs.EnglishVocab;

namespace MiniBilge.Application.Interfaces.Services;

public interface IEnglishVocabQuizService
{
    /// <summary>
    /// Seçili CEFR seviyesindeki kelimelerden, aynı seviye + aynı sözcük türünden dinamik
    /// çeldiricilerle çoktan seçmeli sorular üretir (DB kaynaklı, rastgele).
    /// </summary>
    Task<List<VocabQuestionDto>> GenerateAsync(GenerateVocabQuizRequest request);

    /// <summary>
    /// Quiz tamamlamasını kaydeder: english_vocab_activity (idempotent) + günlük seri (streak).
    /// Yıldız/kart/rozet ödülü ayrıca IAdaptiveQuizService.AwardAsync ile verilir.
    /// </summary>
    Task RecordCompletionAsync(Guid childId, AwardVocabQuizRequest request);
}
