using MiniBilge.Domain.Entities.Base;

namespace MiniBilge.Domain.Entities;

/// <summary>
/// TDK sözlük servisinden doğrulanmış/reddedilmiş kelimelerin cache'i.
/// Yalnızca "tahmin geçerliliği" içindir; wordle_level_pool (hedef kelime havuzu) ile ilgisi yoktur.
/// </summary>
public class TdkWordCache : BaseEntity
{
    /// <summary>Normalize edilmiş (ToUpperInvariant + Trim) kelime.</summary>
    public string   Word      { get; set; } = string.Empty;
    public bool     IsValid   { get; set; }
    public DateTime CheckedAt { get; set; }
}
