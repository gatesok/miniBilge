import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/analytics_service.dart';
import '../models/wordle_models.dart';
import '../services/wordle_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class WordleState {
  final WordleTodayModel? today;
  final bool isLoading;
  final String? error;

  /// Klavyede girilen ama henüz submit edilmemiş tahmin
  final String currentInput;

  /// Klavye renk haritası: harf → en iyi durum (correct > present > absent)
  final Map<String, String> keyColors;

  const WordleState({
    this.today,
    this.isLoading = false,
    this.error,
    this.currentInput = '',
    this.keyColors = const {},
  });

  WordleState copyWith({
    WordleTodayModel? today,
    bool? isLoading,
    String? error,
    String? currentInput,
    Map<String, String>? keyColors,
    bool clearError = false,
  }) => WordleState(
    today: today ?? this.today,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    currentInput: currentInput ?? this.currentInput,
    keyColors: keyColors ?? this.keyColors,
  );

  int get wordLength => today?.wordLength ?? 5;
  int get maxAttempts => today?.maxAttempts ?? 6;
  bool get canSubmit => currentInput.length == wordLength;
  bool get isFinished => today?.finished ?? false;
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class WordleNotifier extends StateNotifier<WordleState> {
  final WordleService _service;
  final String _childId;
  final _analyticsGuard = AnalyticsEventGuard();

  WordleNotifier(this._service, this._childId) : super(const WordleState());

  Future<void> load({String language = 'tr'}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final today = await _service.getToday(
        childId: _childId,
        language: language,
      );
      final keys = _buildKeyColors(today.previousGuesses);
      state = state.copyWith(
        today: today,
        isLoading: false,
        keyColors: keys,
        currentInput: '',
      );
      if (!today.finished) {
        unawaited(
          _analyticsGuard.logOnce(
            'wordle_started',
            AnalyticsEvents.wordleStarted,
            parameters: {'word_length': today.wordLength, 'mode': 'daily'},
          ),
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
      currentInput: state.currentInput.substring(
        0,
        state.currentInput.length - 1,
      ),
    );
  }

  Future<SubmitGuessResponse?> submitGuess({String language = 'tr'}) async {
    if (!state.canSubmit) return null;
    if (state.today == null) return null;

    try {
      final wasFinished = state.isFinished;
      final response = await _service.submitGuess(
        childId: _childId,
        guess: state.currentInput,
        language: language,
      );

      // Önceki tahminlere yeni satırı ekle
      final newGuess = WordleGuessModel(
        guess: state.currentInput,
        pattern: response.pattern,
      );
      final updatedGuesses = [...?state.today?.previousGuesses, newGuess];
      final updatedToday = WordleTodayModel(
        date: state.today!.date,
        wordLength: state.today!.wordLength,
        maxAttempts: state.today!.maxAttempts,
        attemptsUsed: state.today!.attemptsUsed + 1,
        solved: response.solved,
        finished: response.finished,
        hint: state.today!.hint, // hint korunur
        previousGuesses: updatedGuesses,
      );

      final keys = _buildKeyColors(updatedGuesses);
      state = state.copyWith(
        today: updatedToday,
        keyColors: keys,
        currentInput: '',
      );

      if (response.finished && !wasFinished) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.wordleCompleted,
            parameters: {
              'solved': response.solved,
              'attempt_bucket': _attemptBucket(updatedToday.attemptsUsed),
              'mode': 'daily',
            },
          ),
        );
      }

      return response;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  void clearError() => state = state.copyWith(clearError: true);

  // ── Yardımcı ──────────────────────────────────────────────────────────────

  static Map<String, String> _buildKeyColors(List<WordleGuessModel> guesses) {
    const priority = {'correct': 3, 'present': 2, 'absent': 1};
    final map = <String, String>{};
    for (final g in guesses) {
      for (var i = 0; i < g.guess.length && i < g.pattern.length; i++) {
        final letter = g.guess[i];
        final status = g.pattern[i];
        final existing = map[letter];
        if (existing == null ||
            (priority[status] ?? 0) > (priority[existing] ?? 0)) {
          map[letter] = status;
        }
      }
    }
    return map;
  }

  static String _attemptBucket(int attempts) {
    if (attempts <= 2) return '1_2';
    if (attempts <= 4) return '3_4';
    return '5_plus';
  }
}

// ── Provider ──────────────────────────────────────────────────────────────────

final wordleProvider =
    StateNotifierProvider.family<WordleNotifier, WordleState, String>(
      (ref, childId) =>
          WordleNotifier(ref.read(wordleServiceProvider), childId),
    );

/// Stats için ayrı provider (oyun ekranı dışında profil/istatistik sayfası için)
final wordleStatsProvider = FutureProvider.family<WordleStatsModel, String>((
  ref,
  childId,
) async {
  return ref.read(wordleServiceProvider).getStats(childId: childId);
});
