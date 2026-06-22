namespace MiniBilge.Application.Interfaces;

/// <summary>
/// Üretilen ses dosyalarının bulut depolamaya yüklenmesi için soyutlama.
/// Google Cloud Storage, Azure Blob vb. implementasyonlar bu interface'i uygular.
/// </summary>
public interface ITtsAudioStorage
{
    /// <summary>
    /// Ses verisini bulut depolamaya yükler ve public URL döner.
    /// </summary>
    /// <param name="audioData">MP3 byte dizisi</param>
    /// <param name="objectPath">Depolamadaki yol: örn. "podcast/episode-guid/line-guid.mp3"</param>
    Task<string> UploadAsync(byte[] audioData, string objectPath, CancellationToken ct = default);
}
