import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/entertainment_models.dart';
import '../services/entertainment_service.dart';

// ── Topics provider ──────────────────────────────────────────────────────────

final entertainmentTopicsProvider =
    FutureProvider.autoDispose<List<EntertainmentTopicModel>>((ref) async {
  return ref.read(entertainmentServiceProvider).getTopics();
});

// ── Quiz state ───────────────────────────────────────────────────────────────

class EntertainmentQuizState {
  final List<EntertainmentQuestionModel> questions;
  final int     currentIndex;
  final bool    isLoading;
  final String? error;
  final Map<int, String> answers; // index → "A"|"B"|"C"|"D"

  const EntertainmentQuizState({
    this.questions    = const [],
    this.currentIndex = 0,
    this.isLoading    = false,
    this.error,
    this.answers      = const {},
  });

  EntertainmentQuizState copyWith({
    List<EntertainmentQuestionModel>? questions,
    int?    currentIndex,
    bool?   isLoading,
    String? error,
    Map<int, String>? answers,
    bool clearError = false,
  }) => EntertainmentQuizState(
    questions:    questions    ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    isLoading:    isLoading    ?? this.isLoading,
    error:        clearError   ? null : (error ?? this.error),
    answers:      answers      ?? this.answers,
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
    state = state.copyWith(
        isLoading: true, clearError: true,
        questions: [], currentIndex: 0, answers: {});
    try {
      final qs = await _service.generateQuestions(
          topicKey: topicKey, difficulty: difficulty, count: 5);
      state = state.copyWith(questions: qs, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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
