using MiniBilge.Application.DTOs.Challenge;

namespace MiniBilge.Application.Interfaces.Services;

public interface IChallengeService
{
    /// <summary>Arkadaşa meydan okuma gönderir, push bildirim tetikler.</summary>
    /// <param name="actingUserId">
    /// İşlemi yapan (kimliği doğrulanmış) ebeveyn kullanıcı. Yetişkin meydan
    /// okumalarında günlük "adult_challenge" kotasının tüketilmesi için gereklidir.
    /// null geçilirse kota kontrolü uygulanmaz (geriye dönük uyumluluk).
    /// </param>
    Task<ChallengeDto> SendChallengeAsync(SendChallengeDto request, Guid? actingUserId = null);

    /// <summary>Challengee meydan okumayı kabul eder.</summary>
    Task<ChallengeDto> AcceptChallengeAsync(Guid challengeId, Guid challengeeId);

    /// <summary>Challengee meydan okumayı reddeder.</summary>
    Task<ChallengeDto> DeclineChallengeAsync(Guid challengeId, Guid challengeeId);

    /// <summary>Challenger veya challengee skorunu kaydeder; her iki taraf da oynadıysa Completed yapar.</summary>
    Task<ChallengeDto> SubmitScoreAsync(Guid challengeId, Guid childId, int score);

    /// <summary>challengeeId'ye gelen aktif meydan okumaları listeler.</summary>
    Task<List<ChallengeDto>> GetIncomingAsync(Guid challengeeId);

    /// <summary>challengerId'nin gönderdiği aktif meydan okumaları listeler.</summary>
    Task<List<ChallengeDto>> GetOutgoingAsync(Guid challengerId);

    /// <summary>childId'nin tamamlanan / süresi dolan geçmiş kayıtlarını listeler.</summary>
    Task<List<ChallengeDto>> GetHistoryAsync(Guid childId);

    /// <summary>Süresi dolmuş meydan okumaları Expired yapar (background job).</summary>
    Task ExpireOldChallengesAsync();

    /// <summary>Sırası henüz gelmemiş rakibe hatırlatma gönderir (profil başına 2 saat cooldown).</summary>
    Task<ChallengeDto> RemindChallengeAsync(Guid challengeId, Guid requesterId);

    /// <summary>
    /// Yetişkin profilinin bugünkü sıralama (turnuva) puanı üretme durumunu döner.
    /// <paramref name="opponentId"/> verilirse o rakibe karşı uygunluk da hesaplanır.
    /// </summary>
    Task<AdultRankedStatusDto> GetAdultRankedStatusAsync(Guid profileId, Guid? opponentId = null);
}
