using MiniBilge.Application.DTOs.Tournament;

namespace MiniBilge.Application.Interfaces;

/// <summary>P7-M05: Yetişkin haftalık eğlence turnuvası (V1 — sadece sıralama, ödül yok).</summary>
public interface IAdultTournamentService
{
    /// <summary>
    /// Bir eğlence sonucunu bu haftanın kategori satırına işler. Kategori bir eğlence kategorisi
    /// değilse (ör. İngilizce, kelime oyunu) sessizce yok sayılır.
    /// </summary>
    Task RecordResultAsync(Guid childProfileId, string? categoryKey, int points, bool isWin);

    /// <summary>Turnuva kategorileri (eğlence konuları).</summary>
    IReadOnlyList<TournamentCategoryDto> GetCategories();

    /// <summary>Bu haftanın belirtilen kategori sıralaması; me için opsiyonel çocuk profili.</summary>
    Task<TournamentWeekDto> GetWeeklyLeaderboardAsync(string categoryKey, int topN, Guid? meChildProfileId);
}
