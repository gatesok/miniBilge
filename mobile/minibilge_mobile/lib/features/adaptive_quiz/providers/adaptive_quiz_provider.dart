import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/adaptive_quiz_models.dart';
import '../models/adaptive_quiz_config.dart';
import '../services/adaptive_quiz_service.dart';
import '../../child_profile/providers/selected_child_provider.dart';

// ── Zayıf Konu Provider ──────────────────────────────────────────────────────

final weakTopicsProvider =
    FutureProvider.autoDispose<List<WeakTopicModel>>((ref) async {
  final child = ref.watch(selectedChildProvider);
  if (child == null) return [];
  final service = ref.read(adaptiveQuizServiceProvider);
  return service.getWeakTopics(child.id);
});

// ── Soru Üretim State ────────────────────────────────────────────────────────

class AdaptiveQuizState {
  final List<AdaptiveQuestionModel> questions;
  final int    currentIndex;
  final bool   isLoading;
  final String? error;
  final Map<String, String> answers; // questionId → "A"|"B"|"C"|"D"

  const AdaptiveQuizState({
    this.questions    = const [],
    this.currentIndex = 0,
    this.isLoading    = false,
    this.error,
    this.answers      = const {},
  });

  AdaptiveQuizState copyWith({
    List<AdaptiveQuestionModel>? questions,
    int?    currentIndex,
    bool?   isLoading,
    String? error,
    Map<String, String>? answers,
    bool clearError = false,
  }) => AdaptiveQuizState(
    questions:    questions    ?? this.questions,
    currentIndex: currentIndex ?? this.currentIndex,
    isLoading:    isLoading    ?? this.isLoading,
    error:        clearError   ? null : (error ?? this.error),
    answers:      answers      ?? this.answers,
  );

  bool get isDone => currentIndex >= questions.length && questions.isNotEmpty;
  int  get correctCount =>
      answers.entries.where((e) {
        final q = questions.firstWhere(
          (q) => q.id == e.key, orElse: () => questions.first);
        return q.correctAnswer == e.value;
      }).length;
}

class AdaptiveQuizNotifier extends StateNotifier<AdaptiveQuizState> {
  final AdaptiveQuizService _service;
  final String? _childId;

  AdaptiveQuizNotifier(this._service, this._childId)
      : super(const AdaptiveQuizState());

  Future<void> loadFromConfig(AdaptiveQuizConfig config) async {
    state = state.copyWith(isLoading: true, clearError: true,
        questions: [], currentIndex: 0, answers: {});
    try {
      final questions = await _service.generateQuestions(
        childId:     _childId ?? '',
        topicName:   config.topicName,
        subjectName: config.subjectName,
        gradeLevel:  config.gradeLevel,
        difficulty:  config.difficulty,
        count:       5,
      );
      state = state.copyWith(questions: questions, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadQuestions(WeakTopicModel topic, int gradeLevel) async {
    final config = AdaptiveQuizConfig(
      subjectName:  topic.subjectName,
      levelDisplay: topic.topicName,
      topicName:    topic.topicName,
      gradeLevel:   gradeLevel,
      difficulty:   topic.suggestedDifficulty,
    );
    return loadFromConfig(config);
  }

  Future<void> submitAnswer(String questionId, String answer) async {
    final newAnswers = Map<String, String>.from(state.answers)
      ..[questionId] = answer;
    state = state.copyWith(answers: newAnswers);

    // Arka planda kaydet
    try {
      if (_childId != null) {
        await _service.submitAnswer(
          childId: _childId,
          questionId: questionId,
          givenAnswer: answer,
        );
      }
    } catch (_) {}
  }

  void nextQuestion() {
    if (state.currentIndex < state.questions.length) {
      state = state.copyWith(currentIndex: state.currentIndex + 1);
    }
  }

  void reset() => state = const AdaptiveQuizState();
}

final adaptiveQuizProvider =
    StateNotifierProvider<AdaptiveQuizNotifier, AdaptiveQuizState>((ref) {
  final childId = ref.watch(selectedChildProvider)?.id;
  return AdaptiveQuizNotifier(ref.read(adaptiveQuizServiceProvider), childId);
});
