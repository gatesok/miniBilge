import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_provider.dart';
import '../../child_profile/providers/selected_child_provider.dart';
import '../models/podcast_quiz_models.dart';
import '../services/podcast_quiz_service.dart';

// ─── Service Provider ────────────────────────────────────────────────────────

final podcastQuizServiceProvider = Provider<PodcastQuizService>((ref) {
  final dio = ref.read(dioProvider);
  return PodcastQuizService(dio);
});

// ─── Quiz State ───────────────────────────────────────────────────────────────

class PodcastQuizState {
  final List<PodcastQuizQuestion> questions;
  final int currentIndex;
  final String? selectedAnswer;   // null = henüz cevap verilmedi
  final bool isAnswered;          // cevap gösteriliyor mu
  final List<Map<String, String>> collectedAnswers; // submit için
  final bool isLoading;
  final bool isSubmitting;
  final bool isComplete;
  final String? error;

  const PodcastQuizState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswer,
    this.isAnswered = false,
    this.collectedAnswers = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.isComplete = false,
    this.error,
  });

  PodcastQuizQuestion? get currentQuestion =>
      questions.isNotEmpty && currentIndex < questions.length
          ? questions[currentIndex]
          : null;

  bool get isLastQuestion => currentIndex == questions.length - 1;

  PodcastQuizState copyWith({
    List<PodcastQuizQuestion>? questions,
    int? currentIndex,
    String? selectedAnswer,
    bool clearSelectedAnswer = false,
    bool? isAnswered,
    List<Map<String, String>>? collectedAnswers,
    bool? isLoading,
    bool? isSubmitting,
    bool? isComplete,
    String? error,
  }) {
    return PodcastQuizState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswer: clearSelectedAnswer ? null : (selectedAnswer ?? this.selectedAnswer),
      isAnswered: isAnswered ?? this.isAnswered,
      collectedAnswers: collectedAnswers ?? this.collectedAnswers,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isComplete: isComplete ?? this.isComplete,
      error: error ?? this.error,
    );
  }
}

// ─── Notifier ────────────────────────────────────────────────────────────────

class PodcastQuizNotifier extends StateNotifier<PodcastQuizState> {
  final PodcastQuizService _service;
  final String _childId;
  final String _episodeId;

  PodcastQuizNotifier(this._service, this._childId, this._episodeId)
      : super(const PodcastQuizState(isLoading: true));

  Future<void> loadQuestions() async {
    try {
      final questions = await _service.getQuestions(_episodeId);
      state = PodcastQuizState(questions: questions);
    } catch (e) {
      state = PodcastQuizState(error: e.toString());
    }
  }

  /// Şık seçildi — cevabı göster (doğru/yanlış animasyonu için)
  void selectAnswer(String answer) {
    if (state.isAnswered) return;
    state = state.copyWith(
      selectedAnswer: answer,
      isAnswered: true,
      collectedAnswers: [
        ...state.collectedAnswers,
        {'questionId': state.currentQuestion!.id, 'selectedAnswer': answer},
      ],
    );
  }

  /// Sonraki soruya geç veya tamamla
  void nextQuestion() {
    if (!state.isAnswered) return;

    if (state.isLastQuestion) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        clearSelectedAnswer: true,
        isAnswered: false,
      );
    }
  }

  Future<PodcastQuizResult> submitQuiz() async {
    state = state.copyWith(isSubmitting: true);
    try {
      return await _service.submitQuiz(
        episodeId: _episodeId,
        childProfileId: _childId,
        answers: state.collectedAnswers,
      );
    } finally {
      if (mounted) state = state.copyWith(isSubmitting: false);
    }
  }
}

// ─── Provider ────────────────────────────────────────────────────────────────

final podcastQuizProvider = StateNotifierProvider.autoDispose
    .family<PodcastQuizNotifier, PodcastQuizState, String>(
  (ref, episodeId) {
    final service = ref.read(podcastQuizServiceProvider);
    final child = ref.read(selectedChildProvider);
    final notifier = PodcastQuizNotifier(service, child?.id ?? '', episodeId);
    notifier.loadQuestions();
    return notifier;
  },
);

// ─── Last Result Provider ────────────────────────────────────────────────────

final podcastQuizLastResultProvider =
    FutureProvider.family<PodcastQuizResult?, String>((ref, episodeId) async {
  final service = ref.read(podcastQuizServiceProvider);
  final child = ref.watch(selectedChildProvider);
  if (child == null) return null;
  return service.getLastResult(episodeId, child.id);
});
