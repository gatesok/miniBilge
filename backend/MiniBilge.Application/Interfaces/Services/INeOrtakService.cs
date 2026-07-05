using MiniBilge.Application.DTOs.Entertainment;

namespace MiniBilge.Application.Interfaces.Services;

public interface INeOrtakService
{
    /// <summary>
    /// Belirtilen zorlukta 10 adet "Ne Ortak?" sorusu üretir.
    /// Her soru: 4 ipucu + gizli bağlantı + 4 şık + açıklama.
    /// </summary>
    Task<List<NeOrtakQuestionDto>> GenerateAsync(GenerateNeOrtakRequest request);
}
