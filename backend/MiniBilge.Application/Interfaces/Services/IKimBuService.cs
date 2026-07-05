using MiniBilge.Application.DTOs.Entertainment;

namespace MiniBilge.Application.Interfaces.Services;

public interface IKimBuService
{
    /// <summary>
    /// Belirtilen zorlukta 5 konuluk bir "Kim Bu?" turu üretir.
    /// Her konu: 5 sıralı ipucu + 4 çoktan seçmeli şık.
    /// </summary>
    Task<KimBuRoundDto> GenerateAsync(GenerateKimBuRequest request);
}
