import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/tts_service.dart';
import '../../../features/child_profile/providers/selected_child_provider.dart';
import '../models/podcast_models.dart';
import '../services/podcast_progress_store.dart';
import '../services/podcast_service.dart';

// ─── Service Provider ───────────────────────────────────────────────────────

final podcastServiceProvider = Provider<PodcastService>((ref) {
  final dio = ref.read(dioProvider);
  return PodcastService(dio);
});

// ─── Episode List Provider ──────────────────────────────────────────────────

final podcastListProvider =
    FutureProvider.family<List<PodcastEpisodeSummary>, int>((ref, level) async {
  final service = ref.read(podcastServiceProvider);
  return service.getEpisodesByLevel(level);
});

// ─── Player State ───────────────────────────────────────────────────────────

class PodcastPlayerState {
  final PodcastEpisode? episode;
  final bool isLoading;
  final String? error;
  final int currentLineIndex;
  final bool isPlaying;
  final bool showTranslation;
  final double playbackRate;

  // Karaoke highlight: aktif satır içindeki kelime karakter pozisyonları
  final int wordStart;
  final int wordEnd;

  // Ses ataması: speakerName → voiceName (cihazdan)
  final Map<String, String?> voiceAssignment;

  const PodcastPlayerState({
    this.episode,
    this.isLoading = false,
    this.error,
    this.currentLineIndex = 0,
    this.isPlaying = false,
    this.showTranslation = false,
    this.playbackRate = 1.0,
    this.voiceAssignment = const {},
    this.wordStart = -1,
    this.wordEnd = -1,
  });

  PodcastPlayerState copyWith({
    PodcastEpisode? episode,
    bool? isLoading,
    String? error,
    int? currentLineIndex,
    bool? isPlaying,
    bool? showTranslation,
    double? playbackRate,
    Map<String, String?>? voiceAssignment,
    int? wordStart,
    int? wordEnd,
  }) {
    return PodcastPlayerState(
      episode: episode ?? this.episode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentLineIndex: currentLineIndex ?? this.currentLineIndex,
      isPlaying: isPlaying ?? this.isPlaying,
      showTranslation: showTranslation ?? this.showTranslation,
      playbackRate: playbackRate ?? this.playbackRate,
      voiceAssignment: voiceAssignment ?? this.voiceAssignment,
      wordStart: wordStart ?? this.wordStart,
      wordEnd: wordEnd ?? this.wordEnd,
    );
  }
}

class PodcastPlayerNotifier extends StateNotifier<PodcastPlayerState> {
  final PodcastService _service;
  final String _profileId;
  StreamSubscription<void>? _completionSub;
  StreamSubscription<({int start, int end})>? _progressSub;

  PodcastPlayerNotifier(this._service, {String profileId = 'default'})
      : _profileId = profileId,
        super(const PodcastPlayerState());

  /// Episode'u yükler ve cihaz seslerini atar.
  Future<void> loadEpisode(String episodeId) async {
    state = const PodcastPlayerState(isLoading: true);
    try {
      final episode = await _service.getEpisode(episodeId);

      // Cihaz seslerini al
      final voices = await TtsService.getEnglishVoices();

      // Unique konuşmacıları bul (sıralı, tutarlı atama için)
      final speakerEntries = <String, int>{};
      for (final line in episode.lines) {
        speakerEntries.putIfAbsent(line.speakerName, () => line.speakerGender);
      }

      final assignment = <String, String?>{};

      // Kalite skoru: premium=3, enhanced=2, compact/fred=0, diğer=1
      int qualScore(String name) {
        final n = name.toLowerCase();
        if (n.contains('premium')) return 3;
        if (n.contains('enhanced')) return 2;
        if (n.contains('compact') || n.contains('fred')) return 0; // düşük kalite
        return 1;
      }

      // Kalite sıralaması: yüksek kalite önce
      List<Map<String, String>> byQuality(List<Map<String, String>> list) =>
          [...list]..sort((a, b) =>
              qualScore(b['name']!).compareTo(qualScore(a['name']!)));

      // iOS bilinen erkek sesler
      bool isMaleVoice(String n) {
        final l = n.toLowerCase();
        if (l.contains('siri_male') || (l.contains('male') && !l.contains('female'))) {
          return true;
        }
        const names = ['aaron', 'fred', 'daniel', 'oliver', 'gordon', 'arthur',
                       'rishi', 'eddy', 'malcolm', 'reed', 'alex', 'bruce',
                       'thomas', 'tom', 'jack', 'james', 'ryan', 'liam'];
        return names.any((m) => l.contains(m));
      }

      // iOS bilinen kadın sesler
      bool isFemaleVoice(String n) {
        final l = n.toLowerCase();
        if (l.contains('siri_female') || (l.contains('female') && !l.contains('male'))) {
          return true;
        }
        const names = ['samantha', 'karen', 'moira', 'tessa', 'fiona', 'kate',
                       'victoria', 'nicky', 'zoe', 'susan', 'serena', 'sara',
                       'ava', 'nova', 'allison', 'alice', 'siri_f'];
        return names.any((f) => l.contains(f));
      }

      final maleVoices   = byQuality(voices.where((v) => isMaleVoice(v['name']!)).toList());
      final femaleVoices = byQuality(voices.where((v) => isFemaleVoice(v['name']!)).toList());
      final otherVoices  = byQuality(voices.where(
          (v) => !isMaleVoice(v['name']!) && !isFemaleVoice(v['name']!)).toList());

      // En iyi genel ses (kadın-erkek ayrımı olmaksızın, kalite sıralı)
      final allByQuality = byQuality(voices);

      int mIdx = 0, fIdx = 0;
      for (final entry in speakerEntries.entries) {
        final spName   = entry.key;
        final spGender = entry.value; // 0=Male, 1=Female
        if (spGender == 0) {
          // Erkek: önce iyi kaliteli erkek ses ara
          final mPool = maleVoices.isNotEmpty ? maleVoices
              : (otherVoices.isNotEmpty ? otherVoices : <Map<String, String>>[]);
          final bestMale = mPool.isNotEmpty && qualScore(mPool.first['name']!) > 0
              ? mPool.first
              : null;

          if (bestMale != null) {
            // Enhanced/premium erkek ses var — kullan, pitch 0.75 ile doğal erkek tonu
            assignment[spName] = bestMale['name'];
          } else {
            // Compact/eski erkek ses var ya da hiç yok:
            // En iyi genel sesi kullan (büyük ihtimalle Samantha Enhanced).
            // speakWithVoice gender=0 algıladığında pitch 0.75 uygular → belirgin bas ton.
            assignment[spName] = allByQuality.isNotEmpty
                ? allByQuality.first['name']
                : null;
          }
          mIdx++;
        } else {
          // Kadın: female list → other → male (son çare)
          final pool = femaleVoices.isNotEmpty ? femaleVoices
              : (otherVoices.isNotEmpty ? otherVoices : maleVoices);
          assignment[spName] = pool.isNotEmpty ? pool[fIdx % pool.length]['name'] : null;
          fIdx++;
        }
      }

      // Podcast için yüksek kalite ses modu aktifleştir
      await TtsService.configurePodcastMode();

      state = PodcastPlayerState(
        episode: episode,
        voiceAssignment: assignment,
        currentLineIndex: 0,
      );

      // Debug: ses atamalarını göster
      debugPrint('🎤 Mevcut sesler: $voices');
      debugPrint('🎤 Ses ataması: $assignment');
    } catch (e) {
      state = PodcastPlayerState(error: e.toString());
    }
  }

  /// Oynatmayı başlat (mevcut satırdan itibaren).
  Future<void> play() async {
    if (state.episode == null || state.isPlaying) return;
    state = state.copyWith(isPlaying: true);

    _completionSub?.cancel();
    _completionSub = TtsService.onCompleted.listen((_) => _onLineCompleted());

    _progressSub?.cancel();
    _progressSub = TtsService.onWordBoundary.listen((pos) {
      if (!mounted) return;
      state = state.copyWith(wordStart: pos.start, wordEnd: pos.end);
    });

    await _speakCurrentLine();
  }

  /// Duraklat.
  Future<void> pause() async {
    _completionSub?.cancel();
    await TtsService.pause();
    state = state.copyWith(isPlaying: false);
  }

  /// Bir önceki satıra git.
  Future<void> previousLine() async {
    final idx = (state.currentLineIndex - 1).clamp(0, _lastIndex);
    await TtsService.stop();
    state = state.copyWith(currentLineIndex: idx, isPlaying: false);
  }

  /// Bir sonraki satıra git.
  Future<void> nextLine() async {
    final idx = (state.currentLineIndex + 1).clamp(0, _lastIndex);
    await TtsService.stop();
    _completionSub?.cancel();
    state = state.copyWith(currentLineIndex: idx, isPlaying: false);
  }

  /// Belirli bir satıra atla.
  Future<void> seekTo(int index) async {
    await TtsService.stop();
    _completionSub?.cancel();
    state = state.copyWith(currentLineIndex: index, isPlaying: false);
  }

  void toggleTranslation() {
    state = state.copyWith(showTranslation: !state.showTranslation);
  }

  Future<void> setPlaybackRate(double rate) async {
    state = state.copyWith(playbackRate: rate);
  }

  Future<void> _speakCurrentLine() async {
    final episode = state.episode;
    if (episode == null) return;
    final lines = episode.lines;
    if (state.currentLineIndex >= lines.length) {
      // Son satıra gelindi
      state = state.copyWith(isPlaying: false);
      return;
    }
    // Yeni satıra geçince highlight sıfırla
    state = state.copyWith(wordStart: -1, wordEnd: -1);
    final line = lines[state.currentLineIndex];
    final voiceName = state.voiceAssignment[line.speakerName];
    // Progress kaydet (anlık ValueNotifier + disk)
    PodcastProgressStore.saveProgress(
        episode.id, state.currentLineIndex, lines.length,
        profileId: _profileId);
    // Erkek sesler (Aaron compact vb.) daha yavaş — kompanse et.
    final baseRate = line.speakerGender == 0 ? 0.42 : 0.40;
    await TtsService.speakWithVoice(
      line.text,
      voiceName: voiceName,
      gender: line.speakerGender,
      rate: baseRate * state.playbackRate,
    );
  }

  void _onLineCompleted() {
    if (!state.isPlaying) return;
    final episode = state.episode;
    if (episode == null) return;

    final nextIndex = state.currentLineIndex + 1;
    if (nextIndex >= episode.lines.length) {
      // Episode bitti
      state = state.copyWith(isPlaying: false, currentLineIndex: episode.lines.length - 1);
      return;
    }
    state = state.copyWith(currentLineIndex: nextIndex);
    _speakCurrentLine();
  }

  int get _lastIndex => (state.episode?.lines.length ?? 1) - 1;

  @override
  void dispose() {
    _completionSub?.cancel();
    _progressSub?.cancel();
    TtsService.stop();
    TtsService.configureAmbientMode(); // Quiz TTS için ambient moda dön
    super.dispose();
  }
}

final podcastPlayerProvider =
    StateNotifierProvider.autoDispose<PodcastPlayerNotifier, PodcastPlayerState>(
  (ref) {
    final service = ref.read(podcastServiceProvider);
    final profileId = ref.read(selectedChildProvider)?.id ?? 'default';
    return PodcastPlayerNotifier(service, profileId: profileId);
  },
);
