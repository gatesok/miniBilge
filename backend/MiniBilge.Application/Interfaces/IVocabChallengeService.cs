using MiniBilge.Application.DTOs.Writing;

namespace MiniBilge.Application.Interfaces;

public interface IVocabChallengeService
{
    /// <summary>
    /// Çocuğun öğrendiği flashcard kelimelerinden görev üretir.
    /// </summary>
    Task<VocabChallengeTaskDto> GenerateChallengeAsync(GenerateVocabChallengeRequest request);

    /// <summary>
    /// Çocuğun yazdığı metni hedef kelimelerin kullanımı dahil değerlendirir.
    /// </summary>
    Task<VocabChallengeResultDto> EvaluateChallengeAsync(EvaluateVocabChallengeRequest request);
}
