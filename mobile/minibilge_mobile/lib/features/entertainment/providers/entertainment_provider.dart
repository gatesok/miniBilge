import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entertainment_models.dart';
import '../services/entertainment_service.dart';
import '../../../core/services/daily_attempt_service.dart';

// ── Topics provider ──────────────────────────────────────────────────────────

final entertainmentTopicsProvider =
    FutureProvider.autoDispose<List<EntertainmentTopicModel>>((ref) async {
  return ref.read(entertainmentServiceProvider).getTopics();
});

// ── Remaining attempts provider ──────────────────────────────────────────────

final entertainmentRemainingProvider =
    FutureProvider.autoDispose<int>((ref) async {
  return entertainmentAttempts.remaining();
});

// ── Quiz state ───────────────────────────────────────────────────────────────

class EntertainmentQuizState {
  final List<EntertainmentQuestionModel> questions;
  final int     currentIndex;
  final bool    isLoading;
  final String? error;
  final Map<int, String> answers;
  final bool    noAttemptsLeft;

  const EntertainmentQuizState({
    this.questions      = const [],
    this.currentIndex   = 0,
    this.isLoading      = false,
    this.error,
    this.answers        = const {},
    this.noAttemptsLeft = false,
  });

  EntertainmentQuizState copyWith({
    List<EntertainmentQuestionModel>? questions,
    int?    currentIndex,
    bool?   isLoading,
    String? error,
    Map<int, String>? answers,
    bool?   noAttemptsLeft,
    bool clearError = false,
  }) => EntertainmentQuizState(
    questions:      questions      ?? this.questions,
    currentIndex:   currentIndex   ?? this.currentIndex,
    isLoading:      isLoading      ?? this.isLoading,
    error:          clearError     ? null : (error ?? this.error),
    answers:        answers        ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;
  int  get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].correctAnswer == e.value;
  }).length;
}

class EntertainmentQuizNotifier
    extends StateNotifier<EntertainmentQuizState> {
  final EntertainmentService _service;

  EntertainmentQuizNotifier(this._service)
      : super(const EntertainmentQuizState());

  Future<void> load({
    required String topicKey,
    required String difficulty,
  }) async {
    // Hak kontrolü
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = state.copyWith(
        isLoading: true, clearError: true, noAttemptsLeft: false,
        questions: [], currentIndex: 0, answers: {});
    try {
      final qs = await _service.generateQuestions(
          topicKey: topicKey, difficulty: difficulty, count: 10);
      // Hak tüket
      await entertainmentAttempts.consume();
      state = state.copyWith(questions: qs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
  }

  void answer(int index, String choice) {
    final a = Map<int, String>.from(state.answers)..[index] = choice;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void reset() => state = const EntertainmentQuizState();
}

final entertainmentQuizProvider =
    StateNotifierProvider<EntertainmentQuizNotifier, EntertainmentQuizState>(
  (ref) => EntertainmentQuizNotifier(ref.read(entertainmentServiceProvider)),
);

// ── Gerçek mi Uydurma mı? state ──────────────────────────────────────────────

class FactFictionState {
  final List<FactOrFictionQuestionModel> questions;
  final int            currentIndex;
  final bool           isLoading;
  final String?        error;
  final Map<int, bool> answers;       // index → kullanıcı "gerçek" mi dedi?
  final bool           noAttemptsLeft;

  const FactFictionState({
    this.questions      = const [],
    this.currentIndex   = 0,
    this.isLoading      = false,
    this.error,
    this.answers        = const {},
    this.noAttemptsLeft = false,
  });

  FactFictionState copyWith({
    List<FactOrFictionQuestionModel>? questions,
    int?     currentIndex,
    bool?    isLoading,
    String?  error,
    Map<int, bool>? answers,
    bool?    noAttemptsLeft,
    bool     clearError = false,
  }) => FactFictionState(
    questions:      questions      ?? this.questions,
    currentIndex:   currentIndex   ?? this.currentIndex,
    isLoading:      isLoading      ?? this.isLoading,
    error:          clearError     ? null : (error ?? this.error),
    answers:        answers        ?? this.answers,
    noAttemptsLeft: noAttemptsLeft ?? this.noAttemptsLeft,
  );

  bool get isDone =>
      currentIndex >= questions.length && questions.isNotEmpty;

  int get correctCount => answers.entries.where((e) {
    if (e.key >= questions.length) return false;
    return questions[e.key].isReal == e.value;
  }).length;
}

class FactFictionNotifier extends StateNotifier<FactFictionState> {
  final EntertainmentService _service;

  FactFictionNotifier(this._service) : super(const FactFictionState());

  Future<void> load({required String difficulty}) async {
    final remaining = await entertainmentAttempts.remaining();
    if (remaining <= 0) {
      state = state.copyWith(noAttemptsLeft: true);
      return;
    }

    state = state.copyWith(
        isLoading: true, clearError: true, noAttemptsLeft: false,
        questions: [], currentIndex: 0, answers: {});
    try {
      final items = await _service.generateFactFiction(difficulty: difficulty);
      await entertainmentAttempts.consume();
      state = state.copyWith(questions: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addBonusAttempt() async {
    await entertainmentAttempts.addBonus();
    state = state.copyWith(noAttemptsLeft: false);
  }

  void answer(int index, bool userSaysReal) {
    final a = Map<int, bool>.from(state.answers)..[index] = userSaysReal;
    state = state.copyWith(answers: a);
  }

  void next() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void reset() => state = const FactFictionState();
}

final factFictionProvider =
    StateNotifierProvider<FactFictionNotifier, FactFictionState>(
  (ref) => FactFictionNotifier(ref.read(entertainmentServiceProvider)),
);
