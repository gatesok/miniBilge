using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

/// <summary>P7-M05: Yetişkin haftalık eğlence turnuvası kayıtları.</summary>
public interface IAdultTournamentRepository
{
    /// <summary>(çocuk, hafta, kategori) satırına puan/oyun/galibiyet ekler; satır yoksa oluşturur.</summary>
    Task UpsertAsync(Guid childProfileId, DateOnly weekStart, string categoryKey, int points, bool isWin);

    /// <summary>Belirli hafta+kategori için puanı 0'dan büyük kayıtları puana göre azalan sırada döner (ChildProfile dahil).</summary>
    Task<List<AdultTournamentEntry>> GetWeeklyOrderedAsync(DateOnly weekStart, string categoryKey);
}
