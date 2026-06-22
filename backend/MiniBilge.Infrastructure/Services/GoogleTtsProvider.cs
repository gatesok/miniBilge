using Google.Cloud.TextToSpeech.V1;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Options;

namespace MiniBilge.Infrastructure.Services;

public class GoogleTtsProvider : ITtsProvider
{
    private readonly TextToSpeechClient _client;
    private readonly TtsProviderOptions _options;
    private readonly ILogger<GoogleTtsProvider> _logger;

    public GoogleTtsProvider(
        TextToSpeechClient client,
        IOptions<TtsProviderOptions> options,
        ILogger<GoogleTtsProvider> logger)
    {
        _client = client;
        _options = options.Value;
        _logger = logger;
    }

    public async Task<byte[]> SynthesizeAsync(string text, string voiceKey, CancellationToken ct = default)
    {
        var voiceName = ResolveVoiceName(voiceKey);

        _logger.LogDebug("GoogleTtsProvider: voiceKey={VoiceKey} → voiceName={VoiceName}", voiceKey, voiceName);

        var request = new SynthesizeSpeechRequest
        {
            Input = new SynthesisInput { Text = text },
            Voice = new VoiceSelectionParams
            {
                Name = voiceName,
                LanguageCode = ExtractLanguageCode(voiceName)
            },
            AudioConfig = new AudioConfig
            {
                AudioEncoding = AudioEncoding.Mp3,
                SpeakingRate = 0.95,   // Hafif yavaş — çocuk dinleyici kitlesi
                Pitch = 0.0
            }
        };

        var response = await _client.SynthesizeSpeechAsync(request, ct);
        return response.AudioContent.ToByteArray();
    }

    private string ResolveVoiceName(string voiceKey)
    {
        if (_options.VoiceKeys.TryGetValue(voiceKey, out var providerMap) &&
            providerMap.TryGetValue("Google", out var voiceName) &&
            !string.IsNullOrWhiteSpace(voiceName))
        {
            return voiceName;
        }

        // Varsayılan: tanımsız key gelirse nötr bir ses kullan
        _logger.LogWarning("GoogleTtsProvider: '{VoiceKey}' için voice mapping bulunamadı, varsayılan kullanılıyor.", voiceKey);
        return "en-US-Neural2-C";
    }

    /// <summary>
    /// "en-US-Neural2-D" → "en-US"
    /// </summary>
    private static string ExtractLanguageCode(string voiceName)
    {
        var parts = voiceName.Split('-');
        return parts.Length >= 2 ? $"{parts[0]}-{parts[1]}" : "en-US";
    }
}
