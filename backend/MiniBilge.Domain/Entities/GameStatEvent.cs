using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// Oyun istatistiği uygulanmasının idempotency kaydı. Aynı sonuç isteği (aynı
/// idempotency anahtarı) tekrar geldiğinde sayaç/rozetin ikinci kez işlenmesini
/// engellemek için kullanılır. Özellikle eğlence quizi ödül isteklerinde gereklidir.
/// </summary>
public class GameStatEvent : BaseEntity
{
    public Guid ChildProfileId { get; set; }

    /// İstemcinin ürettiği benzersiz sonuç anahtarı.
    public string IdempotencyKey { get; set; } = string.Empty;

    /// 'challenge' | 'live_match' | 'fun'
    public string GameType { get; set; } = string.Empty;

    public string CategoryKey { get; set; } = string.Empty;
}
