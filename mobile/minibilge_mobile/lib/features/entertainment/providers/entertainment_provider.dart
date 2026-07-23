import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/analytics_service.dart';
import '../models/entertainment_models.dart';
import '../services/entertainment_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../../usage/services/daily_usage_service.dart';

String _scoreBucket(int correct, int total) {
  if (total <= 0) return 'unknown';
  final ratio = correct / total;
  if (ratio < 0.4) return 'low';
  if (ratio < 0.8) return 'medium';
  return 'high';
}

void _logAttemptLimit(String gameMode) {
  unawaited(
    AnalyticsService.logEvent(
      AnalyticsEvents.attemptLimitReached,
      parameters: {'feature': gameMode},
    ),
  );
}

// ── Topics provider ──────────────────────────────────────────────────────────

final entertainmentTopicsProvider =
    FutureProvider.autoDispose<List<EntertainmentTopicModel>>((ref) async {
      return ref.read(entertainmentServiceProvider).getTopics();
    });

// ── Remaining attempts provider ──────────────────────────────────────────────

final entertainmentUsageStatusProvider = FutureProvider.autoDispose((
  ref,
) async {
  final childId = ref.watch(selectedChildProvider)?.id;
  if (childId == null) return null;
  return ref
      .read(dailyUsageServiceProvider)
      .getStatus(childId: childId, featureKey: entertainmentUsageKey);
});

final entertainmentRemainingProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final usage = await ref.watch(entertainmentUsageStatusProvider.future);
  return usage?.remaining ?? 0;
});

// ── Quiz state ───────────────────────────────────────────────────────────────

class EntertainmentQuizState {
  final List<EntertainmentQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final Map<int, String> answers;
  final bool noAttemptsLeft;
  final Set<int> shownIds; // DB sorularının tekrar önlenmesi için

  const EntertainmentQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answers = const {},
    this.noAttemptsLeft = false,
    this.shownIds = const {},
  });

  EntertainmentQuizState copyWith({
    List<EntertainmentQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    Map<int, String>? answers,
    bool? noAttemptsLeft,
    Set<int>? shownIds,
    bool clearError = false,
  }) => EntertainmentQuizState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    answers: answers ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
    shownIds: shownIds ?? this.shownIds,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;
  int get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].correctAnswer == e.value;
  }).length;
}

class EntertainmentQuizNotifier extends StateNotifier<EntertainmentQuizState> {
  final EntertainmentService _service;
  final DailyUsageService _usageService;
  final String? _childId;

  EntertainmentQuizNotifier(this._service, this._usageService, this._childId)
    : super(const EntertainmentQuizState());

  Future<void> load({
    required String topicKey,
    required String difficulty,
  }) async {
    // Hak kontrolü
    if (_childId == null) {
      state = state.copyWith(error: 'Profil seçilemedi.');
      return;
    }
    final remaining = (await _usageService.getStatus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    )).remaining;
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      _logAttemptLimit('entertainment_quiz');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      noAttemptsLeft: false,
      questions: [],
      currentIndex: 0,
      answers: {},
    );
    try {
      final qs = await _service.generateQuestions(
        childId: _childId,
        topicKey: topicKey,
        difficulty: difficulty,
        count: 10,
        excludeIds: state.shownIds.toList(),
      );
      // Hak tüket
      // Gösterilen ID'leri kaydet (DB soruları için tekrar önleme)
      final newIds = qs.where((q) => q.id > 0).map((q) => q.id).toSet();
      state = state.copyWith(
        questions: qs,
        isLoading: false,
        shownIds: {...state.shownIds, ...newIds},
      );
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.entertainmentStarted,
          parameters: {
            'game_mode': 'entertainment_quiz',
            'difficulty': difficulty,
          },
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    if (_childId == null) return;
    final usage = await _usageService.grantRewardedBonus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    );
    state = state.copyWith(noAttemptsLeft: usage.remaining <= 0);
  }

  void answer(int index, String choice) {
    final a = Map<int, String>.from(state.answers)..[index] = choice;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      if (state.isDone) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.entertainmentCompleted,
            parameters: {
              'game_mode': 'entertainment_quiz',
              'score_bucket': _scoreBucket(
                state.correctCount,
                state.questions.length,
              ),
            },
          ),
        );
      }
    }
  }

  void reset() => state = const EntertainmentQuizState();
}

final entertainmentQuizProvider =
    StateNotifierProvider<EntertainmentQuizNotifier, EntertainmentQuizState>(
      (ref) => EntertainmentQuizNotifier(
        ref.read(entertainmentServiceProvider),
        ref.read(dailyUsageServiceProvider),
        ref.watch(selectedChildProvider)?.id,
      ),
    );

// ── Gerçek mi Uydurma mı? state ──────────────────────────────────────────────

class FactFictionState {
  final List<FactOrFictionQuestionModel> questions;
  final int currentIndex;
  final bool isLoading;
  final String? error;
  final Map<int, bool> answers; // index → kullanıcı "gerçek" mi dedi?
  final bool noAttemptsLeft;

  const FactFictionState({
    this.questions = const [],
    this.currentIndex = 0,
    this.isLoading = false,
    this.error,
    this.answers = const {},
    this.noAttemptsLeft = false,
  });

  FactFictionState copyWith({
    List<FactOrFictionQuestionModel>? questions,
    int? currentIndex,
    bool? isLoading,
    String? error,
    Map<int, bool>? answers,
    bool? noAttemptsLeft,
    bool clearError = false,
  }) => FactFictionState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    answers: answers ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].isReal == e.value;
  }).length;
}

class FactFictionNotifier extends StateNotifier<FactFictionState> {
  final EntertainmentService _service;
  final DailyUsageService _usageService;
  final String? _childId;

  FactFictionNotifier(this._service, this._usageService, this._childId)
    : super(const FactFictionState());

  Future<void> load({required String difficulty}) async {
    if (_childId == null) {
      state = state.copyWith(error: 'Profil seçilemedi.');
      return;
    }
    final remaining = (await _usageService.getStatus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    )).remaining;
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      _logAttemptLimit('fact_fiction');
      return;
    }

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      noAttemptsLeft: false,
      questions: [],
      currentIndex: 0,
      answers: {},
    );
    try {
      final items = await _service.generateFactFiction(
        childId: _childId,
        difficulty: difficulty,
      );
      state = state.copyWith(questions: items, isLoading: false);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.entertainmentStarted,
          parameters: {'game_mode': 'fact_fiction', 'difficulty': difficulty},
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    if (_childId == null) return;
    final usage = await _usageService.grantRewardedBonus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    );
    state = state.copyWith(noAttemptsLeft: usage.remaining <= 0);
  }

  void answer(int index, bool userSaysReal) {
    final a = Map<int, bool>.from(state.answers)..[index] = userSaysReal;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      if (state.isDone) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.entertainmentCompleted,
            parameters: {
              'game_mode': 'fact_fiction',
              'score_bucket': _scoreBucket(
                state.correctCount,
                state.questions.length,
              ),
            },
          ),
        );
      }
    }
  }

  void reset() => state = const FactFictionState();
}

final factFictionProvider =
    StateNotifierProvider<FactFictionNotifier, FactFictionState>(
      (ref) => FactFictionNotifier(
        ref.read(entertainmentServiceProvider),
        ref.read(dailyUsageServiceProvider),
        ref.watch(selectedChildProvider)?.id,
      ),
    );

// ── Kim Bu? state ─────────────────────────────────────────────────────────────

class KimBuState {
  final KimBuRoundModel? round;
  final int currentSubjectIndex;
  final int hintsRevealed; // 1–5
  final Map<int, bool> answers; // subject index → doğru mu?
  final bool isLoading;
  final String? error;
  final bool noAttemptsLeft;

  const KimBuState({
    this.round,
    this.currentSubjectIndex = 0,
    this.hintsRevealed = 1,
    this.answers = const {},
    this.isLoading = false,
    this.error,
    this.noAttemptsLeft = false,
  });

  KimBuState copyWith({
    KimBuRoundModel? round,
    int? currentSubjectIndex,
    int? hintsRevealed,
    Map<int, bool>? answers,
    bool? isLoading,
    String? error,
    bool? noAttemptsLeft,
    bool clearError = false,
  }) => KimBuState(
    round: round ?? this.round,
    currentSubjectIndex: currentSubjectIndex ?? this.currentSubjectIndex,
    hintsRevealed: hintsRevealed ?? this.hintsRevealed,
    answers: answers ?? this.answers,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get hasRound => round != null && round!.subjects.isNotEmpty;

  /// isDone: son sorunun cevabı verildikten sonra kullanıcı "Sıradaki" butonuna
  /// bastığında true olur — cevap+açıklama gösterildikten SONRA result'a geçilir.
  bool get isDone => hasRound && currentSubjectIndex >= round!.subjects.length;

  /// Doğru tahmin sayısı (0–5) — EntertainmentResultView'e correctCount olarak geçer.
  int get correctCount => answers.values.where((v) => v).length;

  KimBuSubjectModel? get currentSubject =>
      hasRound && currentSubjectIndex < round!.subjects.length
      ? round!.subjects[currentSubjectIndex]
      : null;
}

class KimBuNotifier extends StateNotifier<KimBuState> {
  final EntertainmentService _service;
  final DailyUsageService _usageService;
  final String? _childId;

  KimBuNotifier(this._service, this._usageService, this._childId)
    : super(const KimBuState());

  Future<void> load({required String difficulty}) async {
    if (_childId == null) {
      state = state.copyWith(error: 'Profil seçilemedi.');
      return;
    }
    final remaining = (await _usageService.getStatus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    )).remaining;
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      _logAttemptLimit('kim_bu');
      return;
    }

    state = const KimBuState(isLoading: true);
    try {
      final round = await _service.generateKimBu(
        childId: _childId,
        difficulty: difficulty,
      );
      state = KimBuState(round: round, hintsRevealed: 1);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.entertainmentStarted,
          parameters: {'game_mode': 'kim_bu', 'difficulty': difficulty},
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Bir sonraki ipucunu açar (max 5).
  void revealNextHint() {
    final subject = state.currentSubject;
    if (subject == null) return;
    final maxHints = subject.hints.length;
    if (state.hintsRevealed < maxHints) {
      state = state.copyWith(hintsRevealed: state.hintsRevealed + 1);
    }
  }

  /// Kullanıcı cevap verdi — doğru mu kontrol et, sonraki konuya geç.
  void submitAnswer(String answer) {
    final subject = state.currentSubject;
    if (subject == null) return;
    final isCorrect = answer == subject.correctAnswer;
    final newAnswers = Map<int, bool>.from(state.answers)
      ..[state.currentSubjectIndex] = isCorrect;
    state = state.copyWith(answers: newAnswers);
  }

  /// Cevap gösterildikten sonra sonraki konuya geç.
  void nextSubject() {
    state = state.copyWith(
      currentSubjectIndex: state.currentSubjectIndex + 1,
      hintsRevealed: 1,
    );
    if (state.isDone) {
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.entertainmentCompleted,
          parameters: {
            'game_mode': 'kim_bu',
            'score_bucket': _scoreBucket(
              state.correctCount,
              state.round?.subjects.length ?? 0,
            ),
          },
        ),
      );
    }
  }

  Future<void> addBonusAttempt() async {
    if (_childId == null) return;
    final usage = await _usageService.grantRewardedBonus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    );
    state = state.copyWith(noAttemptsLeft: usage.remaining <= 0);
  }

  void reset() => state = const KimBuState();
}

final kimBuProvider = StateNotifierProvider<KimBuNotifier, KimBuState>(
  (ref) => KimBuNotifier(
    ref.read(entertainmentServiceProvider),
    ref.read(dailyUsageServiceProvider),
    ref.watch(selectedChildProvider)?.id,
  ),
);

// ── Ne Ortak? state ───────────────────────────────────────────────────────────

class NeOrtakState {
  final List<NeOrtakQuestionModel> questions;
  final int currentIndex;
  final Map<int, bool> answers; // index → doğru mu?
  final bool isLoading;
  final String? error;
  final bool noAttemptsLeft;

  const NeOrtakState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.isLoading = false,
    this.error,
    this.noAttemptsLeft = false,
  });

  NeOrtakState copyWith({
    List<NeOrtakQuestionModel>? questions,
    int? currentIndex,
    Map<int, bool>? answers,
    bool? isLoading,
    String? error,
    bool? noAttemptsLeft,
    bool clearError = false,
  }) => NeOrtakState(
    questions: questions ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    answers: answers ?? this.answers,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.values.where((v) => v).length;
}

class NeOrtakNotifier extends StateNotifier<NeOrtakState> {
  final EntertainmentService _service;
  final DailyUsageService _usageService;
  final String? _childId;

  NeOrtakNotifier(this._service, this._usageService, this._childId)
    : super(const NeOrtakState());

  Future<void> load({required String difficulty}) async {
    if (_childId == null) {
      state = state.copyWith(error: 'Profil seçilemedi.');
      return;
    }
    final remaining = (await _usageService.getStatus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    )).remaining;
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      _logAttemptLimit('ne_ortak');
      return;
    }

    state = const NeOrtakState(isLoading: true);
    try {
      final questions = await _service.generateNeOrtak(
        childId: _childId,
        difficulty: difficulty,
      );
      state = NeOrtakState(questions: questions);
      unawaited(
        AnalyticsService.logEvent(
          AnalyticsEvents.entertainmentStarted,
          parameters: {'game_mode': 'ne_ortak', 'difficulty': difficulty},
        ),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void answer(int index, bool isCorrect) {
    final a = Map<int, bool>.from(state.answers)..[index] = isCorrect;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
      if (state.isDone) {
        unawaited(
          AnalyticsService.logEvent(
            AnalyticsEvents.entertainmentCompleted,
            parameters: {
              'game_mode': 'ne_ortak',
              'score_bucket': _scoreBucket(
                state.correctCount,
                state.questions.length,
              ),
            },
          ),
        );
      }
    }
  }

  Future<void> addBonusAttempt() async {
    if (_childId == null) return;
    final usage = await _usageService.grantRewardedBonus(
      childId: _childId,
      featureKey: entertainmentUsageKey,
    );
    state = state.copyWith(noAttemptsLeft: usage.remaining <= 0);
  }

  void reset() => state = const NeOrtakState();
}

final neOrtakProvider = StateNotifierProvider<NeOrtakNotifier, NeOrtakState>(
  (ref) => NeOrtakNotifier(
    ref.read(entertainmentServiceProvider),
    ref.read(dailyUsageServiceProvider),
    ref.watch(selectedChildProvider)?.id,
  ),
);
