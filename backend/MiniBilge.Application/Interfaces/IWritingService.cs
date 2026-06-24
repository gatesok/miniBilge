using MiniBilge.Application.DTOs.Writing;

namespace MiniBilge.Application.Interfaces;

public interface IWritingService
{
    /// <summary>
    /// Verilen CEFR seviyesi (ve opsiyonel podcast bölümü) için GPT tarafından
    /// üretilmiş 3 yazma promptu döndürür.
    /// </summary>
    Task<List<WritingPromptDto>> GeneratePromptsAsync(GeneratePromptsRequest request);

    /// <summary>
    /// Kullanıcının yazdığı metni GPT-4o ile değerlendirir.
    /// ChildProfileId varsa coin/yıldız ödülü de eklenir.
    /// </summary>
    Task<WritingEvaluationResultDto> EvaluateWritingAsync(EvaluateWritingRequest request);
}
