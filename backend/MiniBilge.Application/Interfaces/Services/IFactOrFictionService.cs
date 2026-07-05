using MiniBilge.Application.DTOs.Entertainment;

namespace MiniBilge.Application.Interfaces.Services;

public interface IFactOrFictionService
{
    /// <summary>
    /// Belirtilen zorlukta 10 adet "Gerçek mi Uydurma mı?" ifadesi üretir.
    /// </summary>
    Task<List<FactOrFictionQuestionDto>> GenerateAsync(GenerateFactOrFictionRequest request);
}
