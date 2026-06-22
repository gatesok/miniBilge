import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/tts_service.dart';
import '../models/podcast_models.dart';
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
    );
  }
}

class PodcastPlayerNotifier extends StateNotifier<PodcastPlayerState> {
  final PodcastService _service;
  StreamSubscription<void>? _completionSub;

  PodcastPlayerNotifier(this._service) : super(const PodcastPlayerState());

  /// Episode'u yükler ve cihaz seslerini atar.
  Future<void> loadEpisode(String episodeId) async {
    state = const PodcastPlayerState(isLoading: true);
    try {
      final episode = await _service.getEpisode(episodeId);

      // Cihaz seslerini al ve konuşmacılara ata
      final voices = await TtsService.getEnglishVoices();
      final maleVoices = voices.where((v) {
        final n = v['name']!.toLowerCase();
        return n.contains('daniel') ||
            n.contains('alex') ||
            n.contains('tom') ||
            n.contains('fred') ||
            n.contains('lee') ||
            n.contains('gordon') ||
            !n.contains('samantha') &&
                !n.contains('karen') &&
                !n.contains('moira') &&
                !n.contains('tessa') &&
                !n.contains('veena');
      }).toList();
      final femaleVoices = voices.where((v) {
        final n = v['name']!.toLowerCase();
        return n.contains('samantha') ||
            n.contains('karen') ||
            n.contains('moira') ||
            n.contains('tessa') ||
            n.contains('veena');
      }).toList();

      // Unique konuşmacıları bul ve ses ata
      final speakers = episode.lines
          .map((l) => (l.speakerName, l.speakerGender))
          .toSet()
          .toList();

      int maleIdx = 0;
      int femaleIdx = 0;
      final assignment = <String, String?>{};

      for (final (name, gender) in speakers) {
        if (gender == 1) {
          // Female
          assignment[name] =
              femaleVoices.isNotEmpty ? femaleVoices[femaleIdx % femaleVoices.length]['name'] : null;
          femaleIdx++;
        } else {
          // Male
          assignment[name] =
              maleVoices.isNotEmpty ? maleVoices[maleIdx % maleVoices.length]['name'] : null;
          maleIdx++;
        }
      }

      state = PodcastPlayerState(
        episode: episode,
        voiceAssignment: assignment,
        currentLineIndex: 0,
      );
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
    final line = lines[state.currentLineIndex];
    final voiceName = state.voiceAssignment[line.speakerName];
    await TtsService.speakWithVoice(
      line.text,
      voiceName: voiceName,
      gender: line.speakerGender,
      rate: 0.40 * state.playbackRate,
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
    TtsService.stop();
    super.dispose();
  }
}

final podcastPlayerProvider =
    StateNotifierProvider.autoDispose<PodcastPlayerNotifier, PodcastPlayerState>(
  (ref) {
    final service = ref.read(podcastServiceProvider);
    return PodcastPlayerNotifier(service);
  },
);
