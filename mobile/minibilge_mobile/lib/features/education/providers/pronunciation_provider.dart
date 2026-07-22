import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/services/analytics_service.dart';
import '../models/pronunciation_models.dart';
import '../services/pronunciation_service.dart';

// ─── Service Provider ─────────────────────────────────────────────────────────

final pronunciationServiceProvider = Provider<PronunciationService>((ref) {
  final dio = ref.read(dioProvider);
  return PronunciationService(dio);
});

// ─── State ────────────────────────────────────────────────────────────────────

class PronunciationState {
  final List<String> sentences;
  final bool isLoadingSentences;
  final PronunciationResult? result;
  final bool isEvaluating;
  final String? error;

  const PronunciationState({
    this.sentences = const [],
    this.isLoadingSentences = false,
    this.result,
    this.isEvaluating = false,
    this.error,
  });

  PronunciationState copyWith({
    List<String>? sentences,
    bool? isLoadingSentences,
    PronunciationResult? result,
    bool clearResult = false,
    bool? isEvaluating,
    String? error,
    bool clearError = false,
  }) {
    return PronunciationState(
      sentences: sentences ?? this.sentences,
      isLoadingSentences: isLoadingSentences ?? this.isLoadingSentences,
      result: clearResult ? null : (result ?? this.result),
      isEvaluating: isEvaluating ?? this.isEvaluating,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

class PronunciationNotifier extends StateNotifier<PronunciationState> {
  final PronunciationService _service;

  PronunciationNotifier(this._service) : super(const PronunciationState());
  final _analyticsGuard = AnalyticsEventGuard();

  Future<void> loadSentences(int level, {int count = 10}) async {
    state = state.copyWith(isLoadingSentences: true, clearError: true);
    try {
      final sentences = await _service.getSentencesForLevel(
        level,
        count: count,
      );
      state = state.copyWith(sentences: sentences, isLoadingSentences: false);
      if (sentences.isNotEmpty) {
        unawaited(
          _analyticsGuard.logOnce(
            'activity_started',
            AnalyticsEvents.englishActivityStarted,
            parameters: {'activity_type': 'pronunciation', 'level': level},
          ),
        );
      }
    } catch (error) {
      // Hata durumunda boş liste bırakılır; ekran fallback cümle kullanır
      state = state.copyWith(sentences: const [], isLoadingSentences: false);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.contentLoadFailed,
          parameters: {
            'content_type': 'english_pronunciation',
            'error_type': AnalyticsService.errorType(error),
          },
        ),
      );
    }
  }

  Future<void> evaluate({
    required String targetSentence,
    required String spokenText,
    required String level,
    String? childProfileId,
  }) async {
    state = state.copyWith(
      isEvaluating: true,
      clearError: true,
      clearResult: true,
    );
    try {
      final result = await _service.evaluate(
        targetSentence: targetSentence,
        spokenText: spokenText,
        level: level,
        childProfileId: childProfileId,
      );
      state = state.copyWith(result: result, isEvaluating: false);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.englishActivityCompleted,
          parameters: {
            'activity_type': 'pronunciation',
            'result_bucket': AnalyticsService.resultBucket(result.overallScore),
          },
        ),
      );
    } catch (e) {
      state = state.copyWith(
        isEvaluating: false,
        error: 'Değerlendirme yapılamadı. Lütfen tekrar dene.',
      );
    }
  }

  void reset() => state = state.copyWith(clearResult: true, clearError: true);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final pronunciationProvider =
    StateNotifierProvider.autoDispose<
      PronunciationNotifier,
      PronunciationState
    >((ref) => PronunciationNotifier(ref.read(pronunciationServiceProvider)));
