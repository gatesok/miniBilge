using Microsoft.Extensions.Logging;
using MiniBilge.Application.Interfaces;
using MiniBilge.Application.Interfaces.Repositories;
using MiniBilge.Domain.Enums;

namespace MiniBilge.Application.Services;

public class TtsAudioGeneratorService
{
    private readonly IPodcastRepository _repository;
    private readonly ITtsProvider _ttsProvider;
    private readonly ITtsAudioStorage _audioStorage;
    private readonly ILogger<TtsAudioGeneratorService> _logger;

    public TtsAudioGeneratorService(
        IPodcastRepository repository,
        ITtsProvider ttsProvider,
        ITtsAudioStorage audioStorage,
        ILogger<TtsAudioGeneratorService> logger)
    {
        _repository = repository;
        _ttsProvider = ttsProvider;
        _audioStorage = audioStorage;
        _logger = logger;
    }

    /// <summary>
    /// Episode'un tüm satırları için TTS üretir ve Cloud Storage'a yükler.
    /// Idempotent: AudioUrl zaten dolu olan satırlar atlanır.
    /// </summary>
    public async Task GenerateForEpisodeAsync(Guid episodeId, CancellationToken ct = default)
    {
        var episode = await _repository.GetEpisodeWithLinesAsync(episodeId)
            ?? throw new InvalidOperationException($"Episode bulunamadı: {episodeId}");

        var lines = episode.Lines.OrderBy(l => l.DisplayOrder).ToList();

        // Konuşmacı adına göre sabit VoiceKey ata (episode boyunca tutarlı)
        var voiceKeyMap = BuildVoiceKeyMap(lines.Select(l => (l.SpeakerName, l.SpeakerGender)).Distinct());

        int generated = 0;
        int skipped = 0;

        foreach (var line in lines)
        {
            if (!string.IsNullOrEmpty(line.AudioUrl))
            {
                skipped++;
                continue;
            }

            ct.ThrowIfCancellationRequested();

            var voiceKey = voiceKeyMap[line.SpeakerName];
            var objectPath = $"podcast/{episodeId}/{line.Id}.mp3";

            try
            {
                var audioBytes = await _ttsProvider.SynthesizeAsync(line.Text, voiceKey, ct);
                var url = await _audioStorage.UploadAsync(audioBytes, objectPath, ct);
                await _repository.SaveLineAudioAsync(line.Id, url, voiceKey, ct);

                generated++;
                _logger.LogInformation("TTS üretildi: {Speaker} ({VoiceKey}) → {Url}", line.SpeakerName, voiceKey, url);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "TTS üretim hatası: LineId={LineId}", line.Id);
                throw;
            }
        }

        _logger.LogInformation(
            "Episode {EpisodeId}: {Generated} satır üretildi, {Skipped} atlandı.",
            episodeId, generated, skipped);
    }

    /// <summary>
    /// Her benzersiz konuşmacıya soyut bir VoiceKey atar.
    /// Aynı gender içinde sırayla male_1, male_2 / female_1, female_2 kullanılır.
    /// </summary>
    private static Dictionary<string, string> BuildVoiceKeyMap(
        IEnumerable<(string Name, SpeakerGender Gender)> speakers)
    {
        var map = new Dictionary<string, string>();
        int maleCount = 0;
        int femaleCount = 0;

        foreach (var (name, gender) in speakers)
        {
            if (map.ContainsKey(name)) continue;

            if (gender == SpeakerGender.Male)
            {
                maleCount++;
                map[name] = $"male_{maleCount}";
            }
            else
            {
                femaleCount++;
                map[name] = $"female_{femaleCount}";
            }
        }

        return map;
    }
}
