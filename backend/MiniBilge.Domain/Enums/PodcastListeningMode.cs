namespace MiniBilge.Domain.Enums;

public enum PodcastListeningMode
{
    /// <summary>Cihaz TTS'i kullan (iOS AVSpeechSynthesizer) — internet gerektirmez</summary>
    Offline = 0,

    /// <summary>Bulut TTS ses dosyalarını kullan (Google TTS pre-generated) — internet gerektirir</summary>
    Online = 1
}
