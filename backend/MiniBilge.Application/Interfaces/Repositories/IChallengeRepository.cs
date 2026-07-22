using MiniBilge.Domain.Entities;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Interfaces.Repositories;

public interface IChallengeRepository
{
    /// <summary>Yeni meydan okuma oluşturur.</summary>
    Task<Challenge> CreateAsync(Challenge challenge);

    /// <summary>ID ile getirir (navigation'lar dahil).</summary>
    Task<Challenge?> GetByIdAsync(Guid id);

    /// <summary>challengeeId'ye gelen, henüz cevaplanmamış meydan okumaları getirir.</summary>
    Task<List<Challenge>> GetIncomingAsync(Guid challengeeId);

    /// <summary>challengerId'nin gönderdiği meydan okumaları getirir.</summary>
    Task<List<Challenge>> GetOutgoingAsync(Guid challengerId);

    /// <summary>childId'nin dahil olduğu tamamlanan / süresi dolan geçmiş kayıtları getirir.</summary>
    Task<List<Challenge>> GetHistoryAsync(Guid childId);

    /// <summary>İki kişi arasında hâlâ aktif (Pending/ChallengeeAccepted/ChallengerDone) meydan okuma var mı?</summary>
    Task<bool> HasActiveChallengeAsync(Guid challengerId, Guid challengeeId);

    /// <summary>İki profil arasında belirtilen tarihten sonra oluşturulan soru setlerini getirir.</summary>
    Task<List<Challenge>> GetBetweenSinceAsync(Guid firstProfileId, Guid secondProfileId, DateTime sinceUtc);

    /// <summary>Status ve skor alanlarını günceller.</summary>
    Task UpdateAsync(Challenge challenge);

    /// <summary>LastReminderSentAt alanını günceller.</summary>
    Task UpdateReminderSentAtAsync(Guid challengeId, DateTime sentAt);

    /// <summary>Süresi geçmiş Pending/ChallengeeAccepted/ChallengerDone kayıtları Expired yapar.</summary>
    Task ExpireOldAsync();

    /// <summary>Çocuğun tamamladığı meydan okuma istatistiklerini döner (toplam, kazanılan, kaybedilen).</summary>
    Task<(int Total, int Won, int Lost)> GetStatsAsync(Guid childId);
}
