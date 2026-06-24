import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
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
  final bool isCompleted;   // tüm satırlar tamamlandığında true
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
    this.isCompleted = false,
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
    bool? isCompleted,
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
      isCompleted: isCompleted ?? this.isCompleted,
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
  // 0 = Offline (iOS TTS), 1 = Online (AudioPlayer + pre-generated URL)
  final int _podcastMode;

  StreamSubscription<void>? _completionSub;
  StreamSubscription<({int start, int end})>? _progressSub;
  StreamSubscription? _audioStateSub;
  final AudioPlayer _audioPlayer = AudioPlayer();
  // Her _speakCurrentLine çağrısına özgü nesil sayacı.
  // Tamamlanma listener'lar sadece kendi nesiline ait event'ı işler;
  // eski stop() artığı veya çift-firing event'lar yok sayılır.
  int _speakGen = 0;
  // AudioPlayer'ı kasıtlı durdurduğumuzda true — beklenmedik
  // PlayerState.stopped event'larından ayırt etmek için.
  bool _intentionalAudioStop = false;

  PodcastPlayerNotifier(
    this._service, {
    String profileId = 'default',
    int podcastMode = 0,
  })  : _profileId = profileId,
        _podcastMode = podcastMode,
        super(const PodcastPlayerState());

  /// Episode'u yükler ve (offline modda) cihaz seslerini atar.
  Future<void> loadEpisode(String episodeId) async {
    state = const PodcastPlayerState(isLoading: true);
    try {
      final episode = await _service.getEpisode(episodeId);

      Map<String, String?> assignment = {};

      if (_podcastMode == 0) {
        // Offline: cihaz seslerini ata
        assignment = await _buildVoiceAssignment(episode);
        await TtsService.configurePodcastMode();
      }

      state = PodcastPlayerState(
        episode: episode,
        voiceAssignment: assignment,
        currentLineIndex: 0,
      );

      debugPrint('🎙 PodcastMode=$_podcastMode | voiceAssignment=$assignment');
    } catch (e) {
      state = PodcastPlayerState(error: e.toString());
    }
  }

  /// Oynatmayı başlat (mevcut satırdan itibaren).
  Future<void> play() async {
    if (state.episode == null || state.isPlaying) return;
    state = state.copyWith(isPlaying: true);

    if (_podcastMode == 1) {
      // Online mod: AudioPlayer completion dinle
      _completionSub?.cancel();
      _completionSub = _audioPlayer.onPlayerComplete.listen((_) => _onLineCompleted());
    } else {
      // Offline mod: TTS completion + word boundary dinle
      _completionSub?.cancel();
      _completionSub = TtsService.onCompleted.listen((_) => _onLineCompleted());
      _progressSub?.cancel();
      _progressSub = TtsService.onWordBoundary.listen((pos) {
        if (!mounted) return;
        state = state.copyWith(wordStart: pos.start, wordEnd: pos.end);
      });
    }

    await _speakCurrentLine();
  }

  /// Duraklat.
  Future<void> pause() async {
    _completionSub?.cancel();
    _audioStateSub?.cancel();
    if (_podcastMode == 1) {
      _intentionalAudioStop = true;
      await _audioPlayer.pause();
      _intentionalAudioStop = false;
    } else {
      await TtsService.pause();
    }
    state = state.copyWith(isPlaying: false);
  }

  /// Bir önceki satıra git.
  Future<void> previousLine() async {
    await _stopCurrent();
    final idx = (state.currentLineIndex - 1).clamp(0, _lastIndex);
    state = state.copyWith(currentLineIndex: idx, isPlaying: false);
  }

  /// Bir sonraki satıra git.
  Future<void> nextLine() async {
    await _stopCurrent();
    _completionSub?.cancel();
    final idx = (state.currentLineIndex + 1).clamp(0, _lastIndex);
    state = state.copyWith(currentLineIndex: idx, isPlaying: false);
  }

  /// Belirli bir satıra atla.
  Future<void> seekTo(int index) async {
    await _stopCurrent();
    _completionSub?.cancel();
    state = state.copyWith(currentLineIndex: index, isPlaying: false);
  }

  void toggleTranslation() {
    state = state.copyWith(showTranslation: !state.showTranslation);
  }

  Future<void> setPlaybackRate(double rate) async {
    state = state.copyWith(playbackRate: rate);
    // Oynatma devam ediyorsa hızı anında güncelle
    if (state.isPlaying && _podcastMode == 1) {
      await _audioPlayer.setPlaybackRate(rate);
    }
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  Future<void> _stopCurrent() async {
    if (_podcastMode == 1) {
      _intentionalAudioStop = true;
      await _audioPlayer.stop();
      _intentionalAudioStop = false;
    } else {
      await TtsService.stop();
    }
  }

  Future<void> _speakCurrentLine() async {
    final episode = state.episode;
    if (episode == null) return;
    final lines = episode.lines;
    if (state.currentLineIndex >= lines.length) {
      state = state.copyWith(isPlaying: false);
      return;
    }

    // Bu satıra özgü nesil numarası — stale event'ları süzmek için.
    final gen = ++_speakGen;

    state = state.copyWith(wordStart: -1, wordEnd: -1);
    final line = lines[state.currentLineIndex];

    // Progress kaydet
    PodcastProgressStore.saveProgress(
      episode.id,
      state.currentLineIndex,
      lines.length,
      profileId: _profileId,
    );

    // Online mod: audioUrl varsa AudioPlayer kullan, yoksa TTS'e düş
    if (_podcastMode == 1 && line.audioUrl != null) {
      // Her satırda subscription'ları yenile
      _completionSub?.cancel();
      _completionSub = _audioPlayer.onPlayerComplete.listen((_) {
        if (_speakGen == gen) _onLineCompleted();
      });
      // Beklenmedik duraklama koruması: network hatası, audio session interrupt,
      // bozuk URL gibi durumlarda onPlayerComplete gelmeyebilir;
      // PlayerState.stopped → intentional değilse sonraki satıra geç.
      _audioStateSub?.cancel();
      _audioStateSub = _audioPlayer.onPlayerStateChanged.listen((ps) {
        if (ps == PlayerState.stopped &&
            !_intentionalAudioStop &&
            _speakGen == gen &&
            state.isPlaying) {
          _onLineCompleted();
        }
      });
      try {
        await _audioPlayer.setPlaybackRate(state.playbackRate);
        await _audioPlayer.play(UrlSource(line.audioUrl!));
      } catch (e) {
        debugPrint('❌ AudioPlayer play error (line ${state.currentLineIndex}): $e');
        if (_speakGen == gen && state.isPlaying) _onLineCompleted();
      }
    } else {
      // Offline mod veya audioUrl henüz üretilmemiş → iOS TTS fallback
      // Her satırda TTS subscription'ını güncelle (audioUrl olan satırdan dönüş için)
      _completionSub?.cancel();
      _completionSub = TtsService.onCompleted.listen((_) {
        if (_speakGen == gen) _onLineCompleted();
      });
      _progressSub?.cancel();
      _progressSub = TtsService.onWordBoundary.listen((pos) {
        if (!mounted) return;
        state = state.copyWith(wordStart: pos.start, wordEnd: pos.end);
      });
      final voiceName = state.voiceAssignment[line.speakerName];
      final baseRate = line.speakerGender == 0 ? 0.42 : 0.40;
      await TtsService.speakWithVoice(
        line.text,
        voiceName: voiceName,
        gender: line.speakerGender,
        rate: baseRate * state.playbackRate,
      );
    }
  }

  void _onLineCompleted() {
    if (!state.isPlaying) return;
    final episode = state.episode;
    if (episode == null) return;

    final nextIndex = state.currentLineIndex + 1;
    if (nextIndex >= episode.lines.length) {
      state = state.copyWith(
        isPlaying: false,
        isCompleted: true,
        currentLineIndex: episode.lines.length - 1,
      );
      return;
    }
    state = state.copyWith(currentLineIndex: nextIndex);
    _speakCurrentLine();
  }

  /// Offline mod için cihaz seslerini konuşmacılara ata.
  Future<Map<String, String?>> _buildVoiceAssignment(PodcastEpisode episode) async {
    final voices = await TtsService.getEnglishVoices();

    final speakerEntries = <String, int>{};
    for (final line in episode.lines) {
      speakerEntries.putIfAbsent(line.speakerName, () => line.speakerGender);
    }

    int qualScore(String name) {
      final n = name.toLowerCase();
      if (n.contains('premium')) return 3;
      if (n.contains('enhanced')) return 2;
      if (n.contains('compact') || n.contains('fred')) return 0;
      return 1;
    }

    List<Map<String, String>> byQuality(List<Map<String, String>> list) =>
        [...list]..sort((a, b) =>
            qualScore(b['name']!).compareTo(qualScore(a['name']!)));

    bool isMaleVoice(String n) {
      final l = n.toLowerCase();
      const names = ['aaron', 'fred', 'daniel', 'oliver', 'gordon', 'arthur',
                     'rishi', 'eddy', 'malcolm', 'reed', 'alex', 'bruce',
                     'thomas', 'tom', 'jack', 'james', 'ryan', 'liam'];
      return names.any((m) => l.contains(m));
    }

    bool isFemaleVoice(String n) {
      final l = n.toLowerCase();
      const names = ['samantha', 'karen', 'moira', 'tessa', 'fiona', 'kate',
                     'victoria', 'nicky', 'zoe', 'susan', 'serena', 'sara',
                     'ava', 'nova', 'allison', 'alice'];
      return names.any((f) => l.contains(f));
    }

    final maleVoices   = byQuality(voices.where((v) => isMaleVoice(v['name']!)).toList());
    final femaleVoices = byQuality(voices.where((v) => isFemaleVoice(v['name']!)).toList());
    final otherVoices  = byQuality(voices.where(
        (v) => !isMaleVoice(v['name']!) && !isFemaleVoice(v['name']!)).toList());
    final allByQuality = byQuality(voices);

    final assignment = <String, String?>{};
    int fIdx = 0;

    for (final entry in speakerEntries.entries) {
      final spName   = entry.key;
      final spGender = entry.value;
      if (spGender == 0) {
        final mPool = maleVoices.isNotEmpty ? maleVoices
            : (otherVoices.isNotEmpty ? otherVoices : <Map<String, String>>[]);
        final bestMale = mPool.isNotEmpty && qualScore(mPool.first['name']!) > 0
            ? mPool.first
            : null;
        assignment[spName] = bestMale != null
            ? bestMale['name']
            : (allByQuality.isNotEmpty ? allByQuality.first['name'] : null);
      } else {
        final pool = femaleVoices.isNotEmpty ? femaleVoices
            : (otherVoices.isNotEmpty ? otherVoices : maleVoices);
        assignment[spName] = pool.isNotEmpty ? pool[fIdx % pool.length]['name'] : null;
        fIdx++;
      }
    }

    debugPrint('🎤 Ses ataması (offline): $assignment');
    return assignment;
  }

  int get _lastIndex => (state.episode?.lines.length ?? 1) - 1;

  @override
  void dispose() {
    _completionSub?.cancel();
    _progressSub?.cancel();
    _audioStateSub?.cancel();
    _audioPlayer.dispose();
    TtsService.stop();
    TtsService.configureAmbientMode();
    super.dispose();
  }
}

final podcastPlayerProvider =
    StateNotifierProvider.autoDispose<PodcastPlayerNotifier, PodcastPlayerState>(
  (ref) {
    final service = ref.read(podcastServiceProvider);
    final child = ref.read(selectedChildProvider);
    final profileId = child?.id ?? 'default';
    final podcastMode = child?.podcastListeningMode ?? 0;
    return PodcastPlayerNotifier(service, profileId: profileId, podcastMode: podcastMode);
  },
);
