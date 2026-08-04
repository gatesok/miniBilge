using MiniBilge.Domain.Entities;

namespace MiniBilge.Application.Interfaces.Repositories;

/// <summary>P7-M05: Yetişkin haftalık eğlence turnuvası kayıtları.</summary>
public interface IAdultTournamentRepository
{
    /// <summary>(çocuk, hafta, kategori) satırına puan/oyun/galibiyet ve doğru/cevaplanan sayısı ekler; satır yoksa oluşturur.</summary>
    Task UpsertAsync(Guid childProfileId, DateOnly weekStart, string categoryKey, int points, bool isWin, int correctCount, int answeredCount);

    /// <summary>Belirli hafta+kategori için puanı 0'dan büyük kayıtları puana göre azalan sırada döner (ChildProfile dahil).</summary>
    Task<List<AdultTournamentEntry>> GetWeeklyOrderedAsync(DateOnly weekStart, string categoryKey);

    /// <summary>(çocuk, hafta, kategori) için tek satırı döner; yoksa null.</summary>
    Task<AdultTournamentEntry?> GetEntryAsync(Guid childProfileId, DateOnly weekStart, string categoryKey);
}
