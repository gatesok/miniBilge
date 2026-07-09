import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wordle_level_models.dart';
import '../models/wordle_models.dart';
import '../services/wordle_level_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum WordleLevelPhase {
  idle,       // Henüz başlamadı
  generating, // Kelime üretiliyor
  playing,    // Oynanıyor
  finished,   // Seviye bitti (solved/failed)
  levelUp,    // Seviye geçildi — animasyon için kısa süre
}

class WordleLevelState {
  final WordleLevelStateModel?   levelData;
  final WordleLevelPhase         phase;
  final bool                     isLoading;
  final String?                  error;
  final String                   currentInput;
  final Map<String, String>      keyColors;
  // Son submit sonucu (level-up animasyonu için)
  final WordleLevelSubmitResponse? lastResponse;

  const WordleLevelState({
    this.levelData,
    this.phase         = WordleLevelPhase.idle,
    this.isLoading     = false,
    this.error,
    this.currentInput  = '',
    this.keyColors     = const {},
    this.lastResponse,
  });

  WordleLevelState copyWith({
    WordleLevelStateModel?   levelData,
    WordleLevelPhase?        phase,
    bool?                    isLoading,
    String?                  error,
    String?                  currentInput,
    Map<String, String>?     keyColors,
    WordleLevelSubmitResponse? lastResponse,
    bool clearError   = false,
    bool clearResponse= false,
  }) =>
      WordleLevelState(
        levelData:     levelData     ?? this.levelData,
        phase:         phase         ?? this.phase,
        isLoading:     isLoading     ?? this.isLoading,
        error:         clearError    ? null : (error ?? this.error),
        currentInput:  currentInput  ?? this.currentInput,
        keyColors:     keyColors     ?? this.keyColors,
        lastResponse:  clearResponse ? null : (lastResponse ?? this.lastResponse),
      );

  int get wordLength   => levelData?.wordLength  ?? 5;
  int get maxAttempts  => levelData?.maxAttempts ?? 6;
  bool get canSubmit   => currentInput.length == wordLength;
  bool get isFinished  => levelData?.finished ?? false;

  // Seviye renk teması
  static const _teal   = 0xFF0D4F4F;
  static const _orange = 0xFF7B3000;
  static const _purple = 0xFF2D0B5A;
  static const _dark   = 0xFF0F0F1A;

  List<int> get themeColors {
    final level = levelData?.currentLevel ?? 1;
    if (level <= 25)  return [_teal,   0xFF062E2E];
    if (level <= 75)  return [_orange, 0xFF3D1000];
    if (level <= 150) return [_purple, 0xFF0D0226];
    return [_dark, 0xFF000000];
  }
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WordleLevelNotifier extends StateNotifier<WordleLevelState> {
  final WordleLevelService _service;
  final String             _childId;

  WordleLevelNotifier(this._service, this._childId)
      : super(const WordleLevelState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _service.getCurrentLevel(childId: _childId);
      final keys = _buildKeyColors(data.guesses);
      final phase = data.finished
          ? WordleLevelPhase.finished
          : data.guesses.isEmpty && data.attemptsUsed == 0
              ? WordleLevelPhase.idle
              : WordleLevelPhase.playing;
      state = state.copyWith(
        levelData: data, isLoading: false,
        keyColors: keys, phase: phase,
        currentInput: '',
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> generateWord() async {
    state = state.copyWith(
        phase: WordleLevelPhase.generating, isLoading: true, clearError: true);
    try {
      final data = await _service.generateWord(childId: _childId);
      state = state.copyWith(
        levelData:    data,
        phase:        WordleLevelPhase.playing,
        isLoading:    false,
        currentInput: '',
        keyColors:    {},
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(),
          phase: WordleLevelPhase.idle);
    }
  }

  void addLetter(String letter) {
    if (state.isFinished) return;
    if (state.currentInput.length >= state.wordLength) return;
    state = state.copyWith(currentInput: state.currentInput + letter);
  }

  void removeLetter() {
    if (state.currentInput.isEmpty) return;
    state = state.copyWith(
        currentInput:
            state.currentInput.substring(0, state.currentInput.length - 1));
  }

  Future<WordleLevelSubmitResponse?> submitGuess() async {
    if (!state.canSubmit) return null;
    if (state.levelData == null) return null;

    try {
      final response = await _service.submitGuess(
        childId: _childId,
        guess:   state.currentInput,
      );

      // Local state güncelle
      final newGuess = WordleGuessModel(
        guess:   state.currentInput,
        pattern: response.pattern,
      );
      final updatedGuesses = [...?state.levelData?.guesses, newGuess];
      final updatedData    = WordleLevelStateModel(
        currentLevel:  response.levelUp
            ? (state.levelData!.currentLevel + 1)
            : state.levelData!.currentLevel,
        highestLevel:  state.levelData!.highestLevel,
        wordLength:    state.levelData!.wordLength,
        maxAttempts:   state.levelData!.maxAttempts,
        attemptsUsed:  state.levelData!.attemptsUsed + 1,
        hint:          state.levelData!.hint,
        solved:        response.solved,
        finished:      response.finished,
        skipped:       false,
        skipTickets:   state.levelData!.skipTickets,
        starsEarned:   response.starsEarned,
        guesses:       updatedGuesses,
      );

      final keys  = _buildKeyColors(updatedGuesses);
      final phase = response.finished
          ? (response.levelUp ? WordleLevelPhase.levelUp : WordleLevelPhase.finished)
          : WordleLevelPhase.playing;

      state = state.copyWith(
        levelData:    updatedData,
        keyColors:    keys,
        currentInput: '',
        phase:        phase,
        lastResponse: response,
      );

      return response;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<void> skipLevel() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _service.skipLevel(childId: _childId);
      state = state.copyWith(
        levelData:    data,
        isLoading:    false,
        phase:        WordleLevelPhase.idle,
        currentInput: '',
        keyColors:    {},
        clearResponse: true,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> retryLevel() async {
    state = state.copyWith(isLoading: true, clearError: true,
        phase: WordleLevelPhase.generating);
    try {
      final data = await _service.retryLevel(childId: _childId);
      final keys = _buildKeyColors(data.guesses);
      state = state.copyWith(
        levelData:    data,
        isLoading:    false,
        phase:        WordleLevelPhase.playing,
        currentInput: '',
        keyColors:    keys,
        clearResponse: true,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString(),
          phase: WordleLevelPhase.finished);
    }
  }

  /// Level-up animasyonu bittikten sonra yeni seviyeye geç
  void onLevelUpAnimationDone() {
    state = state.copyWith(
      phase:         WordleLevelPhase.idle,
      currentInput:  '',
      keyColors:     {},
      clearResponse: true,
    );
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Yardımcı ────────────────────────────────────────────────────────────────

  static Map<String, String> _buildKeyColors(List<WordleGuessModel> guesses) {
    const priority = {'correct': 3, 'present': 2, 'absent': 1};
    final map = <String, String>{};
    for (final g in guesses) {
      for (var i = 0; i < g.guess.length && i < g.pattern.length; i++) {
        final letter   = g.guess[i];
        final status   = g.pattern[i];
        final existing = map[letter];
        if (existing == null ||
            (priority[status] ?? 0) > (priority[existing] ?? 0)) {
          map[letter] = status;
        }
      }
    }
    return map;
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final wordleLevelProvider = StateNotifierProvider.family<
    WordleLevelNotifier, WordleLevelState, String>(
  (ref, childId) =>
      WordleLevelNotifier(ref.read(wordleLevelServiceProvider), childId),
);

final wordleLevelStatsProvider =
    FutureProvider.family<WordleLevelStatsModel, String>((ref, childId) =>
        ref.read(wordleLevelServiceProvider).getStats(childId: childId));
